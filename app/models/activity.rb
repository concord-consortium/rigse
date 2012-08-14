class Activity < ActiveRecord::Base
  include JnlpLaunchable

  belongs_to :user
  belongs_to :investigation
  belongs_to :original

  has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"
  
  has_many :learner_activities, :class_name => "Report::LearnerActivity"

  has_many :external_activities, :as => :template

  has_many :sections, :order => :position, :dependent => :destroy do
    def student_only
      find(:all, :conditions => {'teacher_only' => false})
    end
  end
  has_many :pages, :through => :sections
  has_many :teacher_notes, :as => :authored_entity
  has_many :author_notes, :as => :authored_entity

  [ Embeddable::Xhtml,
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
    Embeddable::Smartgraph::RangeQuestion].each do |klass|
      eval %!has_many :#{klass.name[/::(\w+)$/, 1].underscore.pluralize}, :class_name => '#{klass.name}',
      :finder_sql => proc { "SELECT #{klass.table_name}.* FROM #{klass.table_name}
      INNER JOIN page_elements ON #{klass.table_name}.id = page_elements.embeddable_id AND page_elements.embeddable_type = '#{klass.to_s}'
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

  self.extend SearchableModel
  @@searchable_attributes = %w{name description}
  send_update_events_to :investigation

  scope :like, lambda { |name|
    name = "%#{name}%"
    {
     :conditions => ["#{self.table_name}.name LIKE ? OR #{self.table_name}.description LIKE ?", name,name]
    }
  }

  scope :published,
  {
    :conditions =>{:publication_status => "published"}
  }
  
  scope :ordered_by, lambda { |order| { :order => order } }
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

    def search_list(options)
      name = options[:name]
      sort_order = options[:sort_order] || "name ASC"
      if (options[:include_drafts])
        activities = Activity.like(name)
      else
        # activities = Activity.published.like(name)
        activities = Activity.published.like(name)
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

end
