class Activity < ActiveRecord::Base
  include JnlpLaunchable
  include TagDefaults
  MUST_HAVE_NAME = "Your activity must have a name."
  MUST_HAVE_DESCRIPTION = "Please give your activity a description."
  MUST_HAVE_UNIQUE_NAME = "Activity '%{value}' already exists. Please pick a unique name."

  belongs_to :user
  belongs_to :investigation
  belongs_to :original, :class_name => "Activity"

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
    Embeddable::Diy::EmbeddedModel,
    Embeddable::Diy::Sensor,
    Embeddable::Smartgraph::RangeQuestion].each do |klass|
      eval "has_many :#{klass.name[/::(\w+)$/, 1].underscore.pluralize}, :class_name => '#{klass.name}',
      :finder_sql => 'SELECT #{klass.table_name}.* FROM #{klass.table_name}
      INNER JOIN page_elements ON #{klass.table_name}.id = page_elements.embeddable_id AND page_elements.embeddable_type = \"#{klass.to_s}\"
      INNER JOIN pages ON page_elements.page_id = pages.id
      INNER JOIN sections ON pages.section_id = sections.id
      WHERE sections.activity_id = \#\{id\}'"
  end

  has_many :enabled_diy_models, :class_name => 'Diy::Model',
    :finder_sql => 'SELECT diy_models.* FROM diy_models
    INNER JOIN embeddable_diy_models ON diy_models.id = embeddable_diy_models.diy_model_id
    INNER JOIN page_elements ON embeddable_diy_models.id = page_elements.embeddable_id AND page_elements.embeddable_type = "Embeddable::Diy::EmbeddedModel"
    INNER JOIN pages ON page_elements.page_id = pages.id
    INNER JOIN sections ON pages.section_id = sections.id
    WHERE sections.activity_id = #{id} AND page_elements.is_enabled = true'

  has_many :enabled_diy_model_types, :class_name => 'Diy::ModelType',
    :finder_sql => 'SELECT diy_model_types.* FROM diy_model_types
    INNER JOIN diy_models ON diy_model_types.id = diy_models.model_type_id
    INNER JOIN embeddable_diy_models ON diy_models.id = embeddable_diy_models.diy_model_id
    INNER JOIN page_elements ON embeddable_diy_models.id = page_elements.embeddable_id AND page_elements.embeddable_type = "Embeddable::Diy::EmbeddedModel"
    INNER JOIN pages ON page_elements.page_id = pages.id
    INNER JOIN sections ON pages.section_id = sections.id
    WHERE sections.activity_id = #{id} AND page_elements.is_enabled = true'

  # skip predictions, because their probe types are ignored
  has_many :enabled_probes, :class_name => 'Probe::ProbeType',
    :finder_sql => 'SELECT probe_probe_types.* FROM probe_probe_types
    INNER JOIN embeddable_data_collectors ON probe_probe_types.id = embeddable_data_collectors.probe_type_id
    INNER JOIN embeddable_diy_sensors ON embeddable_data_collectors.id = embeddable_diy_sensors.prototype_id
    INNER JOIN page_elements ON embeddable_diy_sensors.id = page_elements.embeddable_id AND page_elements.embeddable_type = "Embeddable::Diy::Sensor"
    INNER JOIN pages ON page_elements.page_id = pages.id
    INNER JOIN sections ON pages.section_id = sections.id
    WHERE sections.activity_id = #{id} AND page_elements.is_enabled = true AND embeddable_diy_sensors.graph_type <> "Prediction"'

  has_many :page_elements,
    :finder_sql => 'SELECT page_elements.* FROM page_elements
    INNER JOIN pages ON page_elements.page_id = pages.id
    INNER JOIN sections ON pages.section_id = sections.id
    WHERE sections.activity_id = #{id}'

  # delegate :saveable_types, :reportable_types, :to => :investigation
  def saveable_types
    Investigation.saveable_types
  end

  def reportable_types
    Investigation.reportable_types
  end

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
  named_scope :published_exemplars, :conditions => {:publication_status => "published", :is_exemplar => true}
  named_scope :published_non_exemplars, :conditions => {:publication_status => "published", :is_exemplar => false}
  named_scope :unarchived, :conditions => ["#{self.table_name}.publication_status <> 'archived'"]

  named_scope :with_sensors, lambda {|*sensors|
    query_parts = []
    data = []
    sensors.each do |s|
      str = '( probe_probe_types.name = ? '
      str += 'AND probe_calibrations.name ' + ((s =~ /#/) ? '= ? ' : 'IS NULL ' )
      str += ')'

      query_parts << str
      data += s.split(/#/)
    end
    query = [
      'sections.is_enabled = true',
      'page_elements.is_enabled = true',
      'page_elements.embeddable_type = "Embeddable::Diy::Sensor"',
      'embeddable_diy_sensors.graph_type <> "Prediction"'
      ].join(' AND ')
    query += ' AND (' + query_parts.join(" OR ") + ')'
    {
      :joins => "INNER JOIN `sections` ON sections.activity_id = activities.id
                 INNER JOIN `pages` ON pages.section_id = sections.id
                 INNER JOIN `page_elements` ON page_elements.page_id = pages.id
                 INNER JOIN `embeddable_diy_sensors` ON `embeddable_diy_sensors`.id = `page_elements`.embeddable_id
                 INNER JOIN `embeddable_data_collectors` ON `embeddable_data_collectors`.id = `embeddable_diy_sensors`.prototype_id
                 INNER JOIN `probe_probe_types` ON `probe_probe_types`.id = `embeddable_data_collectors`.probe_type_id
                 LEFT JOIN `probe_calibrations` ON `probe_calibrations`.probe_type_id = `embeddable_data_collectors`.calibration_id",
      :select => 'activities.*',
      :group => 'activities.id',
      :conditions => [query] + data
    }
  }

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

    def search_list(options)
      name = options[:name]
      if options[:include_drafts]
        activities = Activity.unarchived.like(name)
      else
        activities = Activity.unarchived.published.like(name)
      end

      if options[:grade_levels]
        activities = activities.tagged_with(options[:grade_levels], :any => true)
      end

      if options[:subject_areas]
        activities = activities.tagged_with(options[:subject_areas], :any => true)
      end

      if options[:sensors]
        activities = activities.with_sensors(*options[:sensors])
      end

      portal_clazz = options[:portal_clazz] || (options[:portal_clazz_id] && options[:portal_clazz_id].to_i > 0) ? Portal::Clazz.find(options[:portal_clazz_id].to_i) : nil
      if portal_clazz
        activities = activities - portal_clazz.offerings.map { |o| o.runnable }
      end

      if options[:paginate]
        paginate_options = {
          :page => options[:page] || 1,
          :per_page => options[:per_page] || 20
        }
        # group_by ends up making the auto-count calculation off sometimes
        paginate_options[:total_entries] = activities.count(:select => 'DISTINCT activities.id') if options[:sensors]
        activities = activities.paginate(paginate_options)
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

  # TODO: The next two methods can be extracted to 
  # a more general form: (write tests too)
  # Also they could be improved, they currently require
  # lots of database hits when for example the number of
  # copies is 100. It will take 100 database hits before
  # the code stumbles on 101 as being a unique name.
  def self.name_is_taken(name)
    return true if self.find_by_name(name)
    return false
  end
  def self.gen_unique_name(name)  
    while self.name_is_taken(name)
      number = name[/\d+/]
      if number
        name = name.sub(number,"#{(number.to_i) +1}")
      else
        name = "#{name} (2)"
      end
    end
    return name
  end

  def duplicate(new_owner)
    @return_activity = self.clone  :include => {:sections => {:pages => {:page_elements => :embeddable}}}
    @return_activity.original = self
    @return_activity.user = new_owner
    # this results in a yaml value saved in the status, but fixing it will create inconsistancies since
    # it has been this way for so long
    @return_activity.publication_status = :draft
    @return_activity.is_exemplar = false
    @return_activity.name = Activity.gen_unique_name(self.name)
    # save without validations so the naming validation doesn't stop us from saving
    # this might result in two activities with the same name, but that will either
    # get sorted out below or the user will need to deal with it after editing
    @return_activity.save(false)
    # Check if our generated name is still unique or not
    if(!@return_activity.valid? && @return_activity.errors.invalid?(:name))
      # try again one more time
      @return_activity.name = Activity.gen_unique_name(@return_activity.name)
      # this might still fail, but that is ok because when the user goes to edit it
      # they will forced to change the name at that point, which will be a bit confusing
      # but shouldn't happen very often
      @return_activity.save
    end
    @return_activity.deep_set_user(new_owner)
    @return_activity.re_associate_prediction_graphs
    return @return_activity
  end
  alias copy duplicate

  # attempt to re-link prediction graph sources
  def re_associate_prediction_graphs
    the_predictor = nil
    changed = 0
    self.graphs_and_predictors.each do |graphlike|
      if graphlike.graph_type == "Prediction"
        if graphlike.prediction_graph_destinations.size == 0
          the_predictor = graphlike
        end
      elsif graphlike.graph_type == "Sensor" && the_predictor
        if graphlike.prediction_graph_source.nil?
          graphlike.prediction_graph_source = the_predictor
          graphlike.save
          changed = changed + 1
         the_predictor = nil
        end
      end
    end
    if changed > 0
      message  = "re-associated #{changed} graphables"
      logger.warn message
      self.reload
    end
  end

  # returns an ordered list of graphables.
  def graphs_and_predictors
    ordered_embeddables.select { |e| e.kind_of?(Embeddable::Diy::Sensor) || e.kind_of?(Embeddable::DataCollector) }
  end

  # retuns a list of embeddables ordered by their 
  # position in the activity
  def ordered_embeddables
    self.sections.map { |section|
      section.pages.map { |page|
        page.page_elements.map { |elem|
          elem.embeddable
        }
      }
    }.flatten.uniq
  end

  def probe_and_model_summary
    probes = enabled_probes.uniq.map{|p| p.name }
    models = enabled_diy_model_types.uniq.map{|m| m.name }
    { :probes => probes, :models => models}
  end

  def can_run_lightweight?
    # filter through all the embeddables to make sure they all have lightweight views
    sections.each do |section|
      next unless section.is_enabled?
      section.pages.each do |page|
        next unless page.is_enabled?
        page.page_elements.each do |element|
          next unless element.is_enabled?
          component = element.embeddable
          if !component.respond_to?('can_run_lightweight?') || !component.can_run_lightweight?
            return false
          end
        end
      end
    end
    return true
  end
end
