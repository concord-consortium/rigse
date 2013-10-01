class Activity < ActiveRecord::Base
  include JnlpLaunchable
  include MaterialType

  belongs_to :user
  belongs_to :investigation
  belongs_to :original

  has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"

  has_many :learner_activities, :dependent => :destroy, :class_name => "Report::LearnerActivity"

  has_many :external_activities, :as => :template

  has_many :sections, :order => :position, :dependent => :destroy do
    def student_only
      find(:all, :conditions => {'teacher_only' => false})
    end
  end
  has_many :pages, :through => :sections
  has_many :teacher_notes, :dependent => :destroy, :as => :authored_entity
  has_many :author_notes, :dependent => :destroy, :as => :authored_entity

  # BASE_EMBEDDABLES is defined in config/initializers/embeddables.rb
  BASE_EMBEDDABLES.each do |klass|
      eval %!has_many :#{klass[/::(\w+)$/, 1].underscore.pluralize}, :class_name => '#{klass}',
      :finder_sql => proc { "SELECT #{klass.constantize.table_name}.* FROM #{klass.constantize.table_name}
      INNER JOIN page_elements ON #{klass.constantize.table_name}.id = page_elements.embeddable_id AND page_elements.embeddable_type = '#{klass}'
      INNER JOIN pages ON page_elements.page_id = pages.id
      INNER JOIN sections ON pages.section_id = sections.id
      WHERE sections.activity_id = \#\{id\}" }!
  end

  has_many :page_elements,
    :finder_sql => proc { "SELECT page_elements.* FROM page_elements
    INNER JOIN pages ON page_elements.page_id = pages.id
    INNER JOIN sections ON pages.section_id = sections.id
    WHERE sections.activity_id = #{id}" }

  include ResponseTypes
  include Noteable # convenience methods for notes...
  acts_as_replicatable
  acts_as_list :scope => :investigation
  include Changeable
  include TreeNode
  include Publishable

  searchable do
    text :name
    text :description
    text :description_for_teacher
    text :content do
      nil
    end

    integer :probe_type_ids do
      nil
    end

    text :owner do |act|
      act.user.name
    end
    integer :user_id

    boolean :is_official do
      true # FIXME: Not sure if true should be the hardwired value here
    end

    boolean :published do
      publication_status == 'published'
    end
    boolean :teacher_only

    string  :material_type
    integer :offerings_count
    time    :updated_at
    time    :created_at

    string  :grade_span do |act|
      if (act.investigation && act.investigation.grade_span_expectation)
        act.investigation.grade_span_expectation.grade_span
      else
        nil
      end
    end

    integer :domain_id do |act|
      if (act.investigation && act.investigation.grade_span_expectation && act.investigation.grade_span_expectation.domain)
        inv.grade_span_expectation.domain.id
      else
        nil
      end
    end

  end

  send_update_events_to :investigation

  scope :with_gse, {
    :joins => "left outer JOIN ri_gse_grade_span_expectations on (ri_gse_grade_span_expectations.id = investigations.grade_span_expectation_id) JOIN ri_gse_assessment_targets ON (ri_gse_assessment_targets.id = ri_gse_grade_span_expectations.assessment_target_id) JOIN ri_gse_knowledge_statements ON (ri_gse_knowledge_statements.id = ri_gse_assessment_targets.knowledge_statement_id)"
  }

  scope :without_teacher_only,{
    :conditions =>['activities.teacher_only = 0']
  }

  scope :domain, lambda { |domain_id|
    {
      :conditions => ['ri_gse_knowledge_statements.domain_id in (?)', domain_id]
    }
  }

  scope :grade, lambda { |gs|
    gs = gs.size > 0 ? gs : "%"
    {
      :conditions => ['ri_gse_grade_span_expectations.grade_span in (?) OR ri_gse_grade_span_expectations.grade_span LIKE ?', gs, (gs.class==Array)? gs.join(",") : gs ]
    }
  }

  scope :probe_type, {
    :joins => "INNER JOIN sections ON sections.activity_id = activities.id INNER JOIN pages ON pages.section_id = sections.id INNER JOIN page_elements ON page_elements.page_id = pages.id INNER JOIN embeddable_data_collectors ON embeddable_data_collectors.id = page_elements.embeddable_id AND page_elements.embeddable_type = 'Embeddable::DataCollector' INNER JOIN probe_probe_types ON probe_probe_types.id = embeddable_data_collectors.probe_type_id"
  }

  scope :probe, lambda { |pt|
    pt = pt.size > 0 ? pt.map{|i| i.to_i} : []
    {
      :conditions => ['probe_probe_types.id in (?)', pt ]
    }
  }

  scope :no_probe,{
    :select => "activities.id",
    :joins => "INNER JOIN sections ON sections.activity_id = activities.id INNER JOIN pages ON pages.section_id = sections.id INNER JOIN page_elements ON page_elements.page_id = pages.id INNER JOIN embeddable_data_collectors ON embeddable_data_collectors.id = page_elements.embeddable_id AND page_elements.embeddable_type = 'Embeddable::DataCollector' INNER JOIN probe_probe_types ON probe_probe_types.id = embeddable_data_collectors.probe_type_id"
  }

  scope :activity_group, {
      :group => "#{self.table_name}.id"
    }

  scope :like, lambda { |name|
    name = "%#{name}%"
    {
     :conditions => ["#{self.table_name}.name LIKE ? OR #{self.table_name}.description LIKE ?", name,name]
    }
  }

  scope :investigation,
  {
    :joins => "left outer JOIN investigations ON investigations.id = activities.investigation_id",
  }

  scope :published,
  {
    :conditions =>['activities.publication_status = "published" OR (investigations.publication_status = "published" AND investigations.allow_activity_assignment = 1)']
  }

  scope :directly_published,
  {
    :conditions =>['activities.publication_status = "published"']
  }

  scope :assigned, where('offerings_count > 0')

  scope :ordered_by, lambda { |order| { :order => order } }

  class <<self
    def search_list(options)
      grade_span = options[:grade_span] || ""
      domain_id = []
      # we expect domain_id into always be represented as an array:
      domain_id = [options[:domain_id]].flatten.uniq.compact unless options[:domain_id].blank?
      name = options[:name]
      sort_order = options[:sort_order] || "name ASC"
      probe_type = options[:probe_type] || []

      # the investigation tacked on here is because some of the sql in other scopes assumes the parent
      # investigation is available
      activities = Activity.like(name).investigation

      unless options[:include_drafts]
        activities = activities.published
      end

      if probe_type.length > 0
        if probe_type.include?("0")
          activities = activities.activity_group.where('activities.id not in (?)', Activity.no_probe)
        else
          activities = activities.activity_group.probe_type.probe(probe_type)
        end
      end

      if APP_CONFIG[:use_gse]
        if domain_id.length > 0
          activities = activities.with_gse.domain(domain_id.map{|i| i.to_i})
        end

        if (!grade_span.empty?)
          activities = activities.with_gse.grade(grade_span)
        end
      end

      if options[:without_teacher_only]
        activities = activities.without_teacher_only
      end

      portal_clazz = options[:portal_clazz] || (options[:portal_clazz_id] && options[:portal_clazz_id].to_i > 0) ? Portal::Clazz.find(options[:portal_clazz_id].to_i) : nil
      if portal_clazz
        activities = activities - portal_clazz.offerings.map { |o| o.runnable }
      end
      if activities.respond_to? :ordered_by
        activities = activities.ordered_by(sort_order)
      end
      if options[:paginate]
        activities = activities.paginate(:page => options[:page] || 1, :per_page => options[:per_page] || 20)
      else
        activities
      end

    end

  end

  def parent
    return investigation
  end

  def children
    sections
  end

  def left_nav_panel_width
    300
  end




  def deep_xml
    self.to_xml(
      :include => {
        :teacher_notes=>{
          :except => [:id,:authored_entity_id, :authored_entity_type]
        },
        :sections => {
          :exclude => [:id,:activity_id],
          :include => {
            :teacher_notes=>{
              :except => [:id,:authored_entity_id, :authored_entity_type]
            },
            :pages => {
              :exclude => [:id,:section_id],
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
    )
  end

  @@opening_xhtml = <<-HEREDOC
<h3>Procedures</h3>
<p><em>What activities will you and your students do and how are they connected to the objectives?</em></p>
<p></p>
<h4>What will you be doing?</h4>
<p><em>How do you activate and assess students' prior knowledge and connect it to this new learning?</em></li>
<p></p>
<p><em>How do you get students engaged in this lesson?</em></li>
<p></p>
<h4>What will the students be doing?</h4>
<p><em>Students will discuss the following driving question:</em></p>
<p></p>
<p><em>Key components:</p>
<p></p>
<p><em>Starting conditions:</p>
<p></p>
<p><em>Ability to change variables:</p>
<p></p>
  HEREDOC

  @@engagement_xhtml = <<-HEREDOC
<h3>Engagement</h3>
<h4>What will you be doing?</h4>
<p><em>What questions can you pose to encourage students to take risks and to deepen students' understanding?</em></p>
<p></p>
<p><em>How do you facilitate student discourse?</em></p>
<p></p>
<p><em>How do you facilitate the lesson so that all students are active learners and reflective during this lesson?</em></p>
<p></p>
<p><em>How do you monitor students' learning throughout this lesson?</em></p>
<p></p>
<p><em>What formative assessment is imbedded in the lesson?</em></p>
<p></p>
<h4>What will the students be doing?</h4>
<p></p>
  HEREDOC

  @@closure_xhtml = <<-HEREDOC
<h3>Closure</h3>
<h4>What will you be doing?</h4>
<p><em>What kinds of questions do you ask to get meaningful student feedback?</em></p>
<p></p>
<p><em>What opportunities do you provide for students to share their understandings of the task(s)?</em></p>
<p></p>
<h4>What will the students be doing?</h4>
<p></p>
  HEREDOC

  # TODO: we have to make this container nuetral,
  # using parent / tree structure (children)
  def reportable_elements
    return @reportable_elements if @reportable_elements
    @reportable_elements = []
    unless teacher_only?
      @reportable_elements = sections.collect{|s| s.reportable_elements }.flatten
      @reportable_elements.each{|elem| elem[:activity] = self}
    end
    return @reportable_elements
  end

  def print_listing
    listing = []
    self.sections.each do |s|
      s.pages.each do |p|
        listing << {"#{s.name} #{p.name}" => p}
      end
    end
    listing
  end

  def full_title
    full_title = self.name
    unless self.parent.nil?
      full_title = "#{full_title} | #{self.parent.name}"
    end

    return full_title
  end
end
