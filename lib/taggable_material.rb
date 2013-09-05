module TaggableMaterial
  def self.included(klass)
    klass.send :extend, ClassMethods
    klass.class_eval do
      scope :not_private,
      {
        :conditions => "#{self.table_name}.publication_status IN ('published', 'draft')"
      }

      scope :ordered_by, lambda { |order| { :order => order } }
    end
  end

  module ClassMethods
    # find all materials that are either:
    # - have no 'cohort' tags
    # - have a 'cohort' tag that matches one of the cohort tags of the user
    def cohort_visible_to(user)
      scopes = []

      if (teacher = user.portal_teacher) && ! user.has_role?('admin')
        # if we're not an admin, filter by tags as well
        available_cohorts = Admin::Tag.find_all_by_scope("cohorts")
        if available_cohorts.size > 0
          # this finds all materials with no tags
          scopes << tagged_with(available_cohorts.collect{|c| c.tag }, :exclude => true, :on => :cohorts)
        end

        if teacher.cohort_list.size > 0
          # and match everything with the correct tags
          scopes << tagged_with(teacher.cohort_list, :any => true, :on => :cohorts)
        end
      end

      if scopes.present?
        match_any(scopes)
      else
        # this is a no-op so it shouldn't change the query
        scoped
      end
    end

    # the authored_by filter is unscoped so it will pick up materials regardless of the
    # whether previous scopes or filters took them out. This is so it will show any material
    # authored by the user.
    def authored_by_or_cohort_visible_to(user)
      unscoped.match_any([
        unscoped.authored_by(user),
        cohort_visible_to(user)
        ])
    end

    # some pages allow users to see draft or not_private materials
    # however the main search and assignment page does not unless the material is
    # authored by the user
    def assignable_by(user)
      published.authored_by_or_cohort_visible_to(user)
    end

    def search_list(options)
      grade_span = options[:grade_span] || ""
      sort_order = options[:sort_order] || "name ASC"
      domain_id = (!options[:domain_id].nil? && options[:domain_id].length > 0)? (options[:domain_id].class == Array)? options[:domain_id]:[options[:domain_id]] : options[:domain_id] || []
      probe_type = options[:probe_type] || []

      materials = options[:include_drafts] ? not_private : published

      # make sure this particular model has the official scope
      if materials.klass.respond_to?(:official) && !options[:include_contributed]
        # If param is included, we want *all*; if not, only the Concord ones.
        materials = materials.official
      end

      if options[:user]
        # NOTE filters/scopes that happen before here will be ignored if the user is the author
        materials = materials.authored_by_or_cohort_visible_to(options[:user])
      end

      name = options[:name]
      materials = materials.like(name)

      if probe_type.length > 0 && materials.klass.respond_to?(:probe_type)
        if probe_type.include?("0")
          # FIXME this should just look for materials that have any probe instead of the double
          # negative approach currently being used
          materials = materials.where("#{materials.klass.table_name}.id not in (?)", materials.no_probe)
        else
          materials = materials.probe_type.probe(probe_type)
        end
      end

      if APP_CONFIG[:use_gse] && materials.klass.respond_to?(:with_gse)
        if domain_id.length > 0
          materials = materials.with_gse.domain(domain_id.map{|i| i.to_i})
        end

        if (!grade_span.empty?)
          materials = materials.with_gse.grade(grade_span)
        end
      end

      # make sure to only get one copy of each material
      materials = materials.group("#{materials.klass.table_name}.id")

      portal_clazz = options[:portal_clazz] || (options[:portal_clazz_id] && options[:portal_clazz_id].to_i > 0) ? Portal::Clazz.find(options[:portal_clazz_id].to_i) : nil
      if portal_clazz
        materials = materials - portal_clazz.offerings.map { |o| o.runnable }
      end
      if materials.respond_to? :ordered_by
        materials = materials.ordered_by(sort_order)
      end
      if options[:paginate]
        materials = materials.paginate(:page => options[:page] || 1, :per_page => options[:per_page] || 20)
      end

      # convert to a simple array so the grouping clause above doesn't cause problems
      # if size is called on the Relation object after the group clause, then it counts the size
      # groups not the total size.
      materials.all
    end


    # Special :match_any scope for combining other named scopes in an OR fashion
    #
    # FIXME This is probably terribly inefficient and can probably be done more
    # cleanly in the new Rails 3 ActiveRecord::Relation and Arel features.
    #
    # In addition it should probably be folded into an updated SearchableModel
    #
    # Resources:
    #   http://guides.rubyonrails.org/active_record_querying.html
    #   http://m.onkey.org/active-record-query-interface
    #   http://asciicasts.com/episodes/202-active-record-queries-in-rails-3
    #   http://erniemiller.org/2010/05/11/activerecord-relation-vs-arel/
    #   http://erniemiller.org/2010/03/28/advanced-activerecord-3-queries-with-arel/
    #
    # The basic query conditions look like this: 
    #
    #   (resource_pages.id IN () OR resource_pages.id IN ())
    #
    # An additional set of SQL constraints is generated and placed inside 
    # each IN() clause with this statement:
    #
    #   scope.select('id').to_sql
    #
    # For example this query: 
    #
    #   ResourcePage.search_list( { :name => "abc", :user => @admin_user })
    #
    # results in this sql:
    #
    #   SELECT `resource_pages`.* FROM `resource_pages` 
    #   WHERE (
    #     (
    #       resource_pages.id IN (
    #         SELECT id FROM `resource_pages` 
    #         WHERE `resource_pages`.`publication_status` = 'published' 
    #         AND (resource_pages.name LIKE '%abc%' OR resource_pages.description LIKE '%abc%' OR resource_pages.content LIKE '%abc%')
    #       ) OR resource_pages.id IN (
    #         SELECT id FROM `resource_pages` WHERE `resource_pages`.`user_id` = 22 
    #         AND (resource_pages.name LIKE '%abc%' OR resource_pages.description LIKE '%abc%' OR resource_pages.content LIKE '%abc%')
    #       )
    #     )
    #   )
    #
    def match_any(scopes)
      table_name_dot_id = "#{self.table_name}.id"
      conditions = scopes.map { |scope| "#{table_name_dot_id} IN (#{scope.select(table_name_dot_id).to_sql})" }.join(" OR ")
      where("(#{conditions})")
    end

    # add materials that were authored by the user
    def authored_by(user)
      where(:user_id => user.id)
    end
  end
end