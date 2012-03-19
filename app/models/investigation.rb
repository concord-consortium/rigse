class Investigation < ActiveRecord::Base
  include JnlpLaunchable

  # cattr_accessor :publication_states

  belongs_to :user
  belongs_to :grade_span_expectation, :class_name => 'RiGse::GradeSpanExpectation'
  has_many :activities, :order => :position, :dependent => :destroy do
    def student_only
      find(:all, :conditions => {'teacher_only' => false})
    end
  end
  has_many :teacher_notes, :dependent => :destroy, :as => :authored_entity
  has_many :author_notes, :dependent => :destroy, :as => :authored_entity

  has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"

  @@embeddable_klasses = [
    Embeddable::Xhtml,
    Embeddable::OpenResponse,
    Embeddable::MultipleChoice,
    Embeddable::DataTable,
    Embeddable::DrawingTool,
    Embeddable::DataCollector,
    Embeddable::LabBookSnapshot,
    Embeddable::InnerPage,
    Embeddable::MwModelerPage,
    Embeddable::NLogoModel,
    Embeddable::RawOtml,
    Embeddable::Biologica::World,
    Embeddable::Biologica::Organism,
    Embeddable::Biologica::StaticOrganism,
    Embeddable::Biologica::Chromosome,
    Embeddable::Biologica::ChromosomeZoom,
    Embeddable::Biologica::BreedOffspring,
    Embeddable::Biologica::Pedigree,
    Embeddable::Biologica::MultipleOrganism,
    Embeddable::Biologica::MeiosisView,
    Embeddable::Smartgraph::RangeQuestion ]

  @@embeddable_klasses.each do |klass|
    eval %!has_many :#{klass.name[/::(\w+)$/, 1].underscore.pluralize}, :class_name => '#{klass.name}',
      :finder_sql => proc { "SELECT #{klass.table_name}.* FROM #{klass.table_name}
      INNER JOIN page_elements ON #{klass.table_name}.id = page_elements.embeddable_id AND page_elements.embeddable_type = '#{klass.to_s}'
      INNER JOIN pages ON page_elements.page_id = pages.id
      INNER JOIN sections ON pages.section_id = sections.id
      INNER JOIN activities ON sections.activity_id = activities.id
      WHERE activities.investigation_id = \#\{id\}" }!
  end

  has_many :page_elements,
    :finder_sql => proc { "SELECT page_elements.* FROM page_elements
    INNER JOIN pages ON page_elements.page_id = pages.id
    INNER JOIN sections ON pages.section_id = sections.id
    INNER JOIN activities ON sections.activity_id = activities.id
    WHERE activities.investigation_id = #{id}" }

  has_many :sections,
    :finder_sql => proc { "SELECT sections.* FROM sections
    INNER JOIN activities ON sections.activity_id = activities.id
    WHERE activities.investigation_id = #{id}" }

  has_many :student_sections, :class_name => Section.to_s,
    :finder_sql => proc { "SELECT sections.* FROM sections
    INNER JOIN activities ON sections.activity_id = activities.id AND activities.teacher_only = 0
    WHERE activities.investigation_id = #{id} AND sections.teacher_only = 0" }

  has_many :pages,
    :finder_sql => proc { "SELECT pages.* FROM pages
    INNER JOIN sections ON pages.section_id = sections.id
    INNER JOIN activities ON sections.activity_id = activities.id
    WHERE activities.investigation_id = #{id}" }

  has_many :student_pages, :class_name => Page.to_s,
    :finder_sql => proc { "SELECT pages.* FROM pages
    INNER JOIN sections ON pages.section_id = sections.id AND sections.teacher_only = 0
    INNER JOIN activities ON sections.activity_id = activities.id AND activities.teacher_only = 0
    WHERE activities.investigation_id = #{id} AND pages.teacher_only = 0" }

  acts_as_replicatable

  include Publishable

  # for convenience (will not work in find_by_* &etc.)
  [:grade_span, :domain].each { |m| delegate m, :to => :grade_span_expectation }

  scope :assigned, where('investigations.offerings_count > 0')
  #
  # IMPORTANT: Use with_gse if you are also going to use domain and grade params... eg:
  # Investigation.with_gse.grade('9-11') == good
  # Investigation.grade('9-11') == bad
  #
  scope :with_gse, {
    :joins => "left outer JOIN ri_gse_grade_span_expectations on (ri_gse_grade_span_expectations.id = investigations.grade_span_expectation_id) JOIN ri_gse_assessment_targets ON (ri_gse_assessment_targets.id = ri_gse_grade_span_expectations.assessment_target_id) JOIN ri_gse_knowledge_statements ON (ri_gse_knowledge_statements.id = ri_gse_assessment_targets.knowledge_statement_id)"
  }

  scope :domain, lambda { |domain_id|
    {
      :conditions => ['ri_gse_knowledge_statements.domain_id = ?', domain_id]
    }
  }

  scope :grade, lambda { |gs|
    gs = gs.size > 0 ? gs : "%"
    {
      :conditions => ['ri_gse_grade_span_expectations.grade_span LIKE ?', gs ]
    }
  }

  scope :like, lambda { |name|
    name = "%#{name}%"
    {
     :conditions => ["investigations.name LIKE ? OR investigations.description LIKE ?", name,name]
    }
  }

  scope :ordered_by, lambda { |order| { :order => order } }

  include Changeable
  include Noteable # convenience methods for notes...

  self.extend SearchableModel
  @@searchable_attributes = %w{name description publication_status}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end


    def saveable_types
      [ Saveable::OpenResponse, Saveable::MultipleChoice, Saveable::ImageQuestion ]
    end

    def reportable_types
      [ Embeddable::OpenResponse, Embeddable::MultipleChoice, Embeddable::ImageQuestion ]
    end

    def find_by_grade_span_and_domain_id(grade_span,domain_id)
      @grade_span_expectations = RiGse::GradeSpanExpectation.find(:all, :include =>:knowledge_statements, :conditions => ['grade_span LIKE ?', grade_span])
      @investigations = @grade_span_expectations.map { |gse| gse.investigations }.flatten.compact
      # @investigations.flatten!.compact!
    end

    def search_list(options)
      grade_span = options[:grade_span] || ""
      sort_order = options[:sort_order] || "name ASC"
      domain_id = options[:domain_id].to_i
      name = options[:name]
      if APP_CONFIG[:use_gse]
        if domain_id > 0
          if (options[:include_drafts])
            investigations = Investigation.like(name).with_gse.grade(grade_span).domain(domain_id)
          else
            investigations = Investigation.published.like(name).with_gse.grade(grade_span).domain(domain_id)
          end
        elsif (!grade_span.empty?)
          if (options[:include_drafts])
            investigations = Investigation.like(name).with_gse.grade(grade_span)
          else
            investigations = Investigation.published.like(name).with_gse.grade(grade_span)
          end
        else
          if (options[:include_drafts])
            investigations = Investigation.like(name)
          else
            investigations = Investigation.published.like(name)
          end
        end
      else
        if (options[:include_drafts])
          investigations = Investigation.like(name)
        else
          investigations = Investigation.published.like(name)
        end
      end

      if investigations.respond_to? :ordered_by
        investigations = investigations.ordered_by(sort_order)
      end

      portal_clazz = options[:portal_clazz] || (options[:portal_clazz_id] && options[:portal_clazz_id].to_i > 0) ? Portal::Clazz.find(options[:portal_clazz_id].to_i) : nil
      if portal_clazz
        investigations = investigations - portal_clazz.offerings.map { |o| o.runnable }
      end

      if options[:paginate]
        investigations = investigations.paginate(:page => options[:page] || 1, :per_page => options[:per_page] || 20)
      else
        investigations
      end
    end

  end

  def saveable_types
    self.class.saveable_types
  end

  def reportable_types
    self.class.reportable_types
  end

  # Enables a teacher note to call the investigation method of an
  # authored_entity to find the relavent investigation
  def investigation
    self
  end

  after_save :add_author_role_to_use
  
  def add_author_role_to_use
    if self.user
      self.user.add_role('author')
    end
  end

  def left_nav_panel_width
     300
  end

  def parent
    return nil
  end

  def children
    return activities
  end

  include TreeNode


  def deep_xml
    self.to_xml(
      :include => {
        :teacher_notes=>{
          :except => [:id,:authored_entity_id, :authored_entity_type]
        },
        :activities => {
          :exlclude => [:id,:investigation_id],
          :include => {
            :sections => {
              :exlclude => [:id,:activity_id],
              :include => {
                :teacher_notes=>{
                  :except => [:id,:authored_entity_id, :authored_entity_type]
                },
                :pages => {
                  :exlclude => [:id,:section_id],
                  :include => {
                    :teacher_notes=>{
                      :except => [:id,:authored_entity_id, :authored_entity_type]
                    },
                    :page_elements => {
                      :except => [:id,:page_id],
                      :include => {
                        :embeddable => {
                          :except => [:id,:embeddable_type,:embeddable_id]
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    )
  end



  def duplicate(new_owner)
    @return_investigation = deep_clone :no_duplicates => true, :never_clone => [:uuid, :created_at, :updated_at, :publication_status], :include => {:activities => {:sections => :pages}}
    @return_investigation.user = new_owner
    @return_investigation.name = "copy of #{self.name}"
    @return_investigation.deep_set_user(new_owner)
    @return_investigation.publication_status = :draft
    @return_investigation.offerings_count = 0
    return @return_investigation
  end

  def duplicateable?(user)
    user.has_role?("admin") || user.has_role?("manager") || user.has_role?("author") || user.has_role?("researcher")
  end

  def print_listing
    listing = []
    self.activities.each do |a|
      a.sections.each do |s|
        listing << {"#{a.name} #{s.name}" => s}
      end
    end
    listing
  end

  # TODO: we have to make this container nuetral,
  # using parent / tree structure (children)
  def reportable_elements
    return @reportable_elements if @reportable_elements
    @reportable_elements = activities.collect{|a| a.reportable_elements }.flatten
    @reportable_elements.each{|elem| elem[:investigation] = self}
    return @reportable_elements
  end

  # return a list of broken parts.
  def broken_parts
    page_elements.select { |pe| pe.embeddable.nil? }
  end

  # is there something wrong with this investigation?
  def broken?
    self.broken_parts.size > 0
  end

  # is it 'safe' to modify this investigation?
  # TODO: a more thorough check.
  def can_be_modified?
    self.offerings.each do |o|
      return false if o.can_be_deleted? == false
    end
    return true
  end
  
  # Is it 'safe' to delete this investigation?
  def can_be_deleted?
    return can_be_modified?
  end

  # Investigation#broken
  # return a collection broken investigations
  def self.broken
    self.all.select { |i| i.broken? }
  end

  # Investigation#broken_report
  # print a list of broken investigations
  def self.broken_report
    self.broken.each do |i|
      puts "#{i.id} #{i.name}  #{i.broken_parts.size} #{i.offerings.map {|o| o.learners.size}}"
    end
  end

  # Investigation#delete_broken
  # delete broken investigations which can_be_deleted
  def self.delete_broken
    self.broken.each do |i|
      if i.can_be_deleted?
        i.destroy
      end
    end
  end

end
