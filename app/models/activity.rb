class Activity < ActiveRecord::Base
  include JnlpLaunchable
  include SearchModelInterface

  belongs_to :user
  belongs_to :investigation
  belongs_to :original

  has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"

  has_many :materials_collection_items, :dependent => :destroy, :as => :material
  has_many :materials_collections, :through => :materials_collection_items

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

  has_many :project_materials, :class_name => "Admin::ProjectMaterial", :as => :material, :dependent => :destroy
  has_many :projects, :class_name => "Admin::Project", :through => :project_materials

  # BASE_EMBEDDABLES is defined in config/initializers/embeddables.rb
  # This block adds a has_many for each embeddable type to this model.
  # TODO We don't want Embeddable::Iframe showing up in any menus, so inject it here. It's used by LARA.
  (BASE_EMBEDDABLES + ["Embeddable::Iframe"]).each do |klass|
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
    string :name
    text :description
    text :description_for_teacher
    text :content do
      nil
    end

    text :owner do |act|
      act.user && act.user.name
    end
    integer :user_id

    boolean :published do |act|
      if act.investigation
        act.investigation.published?
      else
        act.published?
      end
    end

    integer :probe_type_ids, :multiple => true do |act|
      act.data_collectors.map { |dc| dc.probe_type_id }.compact
    end

    boolean :no_probes do |act|
      act.data_collectors.map { |dc| dc.probe_type_id }.compact.size < 1
    end

    boolean :teacher_only

    integer :offerings_count do |act|
      total = 0
      if act.investigation
        total += act.investigation.offerings_count
      end
      total += act.offerings_count
    end
    boolean :is_official
    boolean :is_template

    time    :updated_at
    time    :created_at

    string  :grade_span
    integer :domain_id
    string  :material_type
    string  :java_requirements
    string  :cohorts, :multiple => true do
      cohort_list
    end
    string  :grade_levels, :multiple => true do
      grade_level_list
    end
    string  :subject_areas, :multiple => true do
      subject_area_list
    end
    string :projects, :multiple => true do
      projects.map { |p| p.name }.compact
    end
  end

  send_update_events_to :investigation
  delegate :domain_id, :grade_span, :to => :investigation, :allow_nil => true

  # TODO: Which of these scopes can be removed?
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
  # End scope weeding zone

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

  def question_number(embeddable)
    found_index = reportable_elements.find_index { |e| e[:embeddable] == embeddable}
    return -1 unless found_index
    return found_index + 1
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

  def is_official
    true # FIXME: Not sure if true should be the hardwired value here
  end

  def is_template
    if (investigation && investigation.external_activities.compact.length > 0)
      return true
    end
    return external_activities.compact.length > 0
  end

end
