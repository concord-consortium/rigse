class Activity < ActiveRecord::Base
  include JnlpLaunchable
  include TagDefaults
  MUST_HAVE_NAME = "Your activity must have a name."
  MUST_HAVE_DESCRIPTION = "Please give your activity a description."
  MUST_HAVE_UNIQUE_NAME = "Activity '%{value}' already exists. Please pick a unique name."

  belongs_to :user
  belongs_to :investigation
  belongs_to :original

  has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"

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
      eval "has_many :#{klass.name[/::(\w+)$/, 1].underscore.pluralize}, :class_name => '#{klass.name}',
      :finder_sql => 'SELECT #{klass.table_name}.* FROM #{klass.table_name}
      INNER JOIN page_elements ON #{klass.table_name}.id = page_elements.embeddable_id AND page_elements.embeddable_type = \"#{klass.to_s}\"
      INNER JOIN pages ON page_elements.page_id = pages.id
      INNER JOIN sections ON pages.section_id = sections.id
      WHERE sections.activity_id = \#\{id\}'"
  end

  has_many :page_elements,
    :finder_sql => 'SELECT page_elements.* FROM page_elements
    INNER JOIN pages ON page_elements.page_id = pages.id
    INNER JOIN sections ON pages.section_id = sections.id
    WHERE sections.activity_id = #{id}'

  delegate :saveable_types, :reportable_types, :to => :investigation
  acts_as_replicatable
  acts_as_taggable_on :grade_levels, :subject_areas, :units, :tags
  acts_as_list :scope => :investigation


  validates_presence_of :name, :message => Activity::MUST_HAVE_NAME 
  validates_presence_of :description,
    :if => Proc.new { |a| Admin::Project.require_activity_descriptions },
    :message => Activity::MUST_HAVE_DESCRIPTION
  validates_uniqueness_of :name,
    :if => Proc.new { |a| Admin::Project.unique_activity_names },
    :message => Activity::MUST_HAVE_UNIQUE_NAME

  include Noteable # convinience methods for notes...
  include Changeable
  include TreeNode
  include Publishable
  include HasPedigree
  self.extend SearchableModel
  @@searchable_attributes = %w{name description}
  send_update_events_to :investigation

  named_scope :like, lambda { |name|
    name = "%#{name}%"
    {
     :conditions => ["#{self.table_name}.name LIKE ? OR #{self.table_name}.description LIKE ?", name,name]
    }
  }
  
  named_scope :published, :conditions => {:publication_status => "published"}
  named_scope :templates, :conditions => {:is_template => true}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

    def display_name
      "Activity"
    end

    def search_list(options)
      name = options[:name]
      if (options[:include_drafts])
        activities = Activity.like(name)
      else
        activities = Activity.published.like(name)
      end

      portal_clazz = options[:portal_clazz] || (options[:portal_clazz_id] && options[:portal_clazz_id].to_i > 0) ? Portal::Clazz.find(options[:portal_clazz_id].to_i) : nil
      if portal_clazz
        activities = activities - portal_clazz.offerings.map { |o| o.runnable }
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

  def self.display_name
    'Activity'
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

  def duplicate(new_owner)
    @return_actvitiy = self.clone  :include => {:sections => {:pages => {:page_elements => :embeddable}}}
    @return_actvitiy.user = new_owner
    @return_actvitiy.name = "copy of #{self.name}"
    @return_actvitiy.deep_set_user(new_owner)
    @return_actvitiy.publication_status = :draft
    return @return_actvitiy
  end
  alias copy duplicate
end
