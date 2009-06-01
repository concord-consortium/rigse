class DataCollector < ActiveRecord::Base
  belongs_to :user
  belongs_to :probe_type

  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  
  belongs_to :prediction_graph_source,
    :class_name => "DataCollector",
    :foreign_key => "prediction_graph_id"

  has_many :prediction_graph_destinations,
    :class_name => "DataCollector",
    :foreign_key => "prediction_graph_id"

  serialize :data_store_values
  
  acts_as_replicatable
  
  include Changeable
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{uuid name description title x_axis_label x_axis_units y_axis_label y_axis_units}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
  def other_data_collectors_in_activity_scope(scope)
    if scope && scope.class != DataCollector
      scope.activity.data_collectors - [self]
    else
      []
    end
  end
  
  def self.prediction_graphs
    DataCollector.find_all_by_graph_type_id(2)
  end
  
  def probe_type=(probe_type)
    self.probe_type_id = probe_type.id
    self.title = "#{probe_type.name} Data Collector"
    self.name = self.title
    self.y_axis_label = probe_type.name
    self.y_axis_units = probe_type.unit
    self.y_axis_min = probe_type.min
    self.y_axis_max = probe_type.max
    # self.x_axis_label
    # self.x_axis_units
    # self.x_axis_min
    # self.x_axis_max
  end

  def self.graph_types
    [["Sensor", 1], ["Prediction", 2], ["Static", 3]]
  end
  
  def graph_type_id
    self[:graph_type_id] || 1
  end

  def graph_type_id=(gid)
    self[:graph_type_id] = gid
  end

  def graph_type
    DataCollector.graph_types[graph_type_id-1][0]
  end

  def y_axis_title
    "#{self.y_axis_label} (#{self.y_axis_units})"
  end

  def x_axis_title
    "#{self.x_axis_label} (#{self.x_axis_units})"
  end

  DISTANCE_PROBE_TYPE = ProbeType.find_by_name('Distance')
  
  default_value_for :name, "Data Graph"
  default_value_for :description, "Data Collector Graphs can be used for sensor data or predictions."

  default_value_for :y_axis_label, "Distance"
  
  default_values :x_axis_min                  =>  0,
                 :x_axis_max                  =>  30,
                 :x_axis_label                =>  "Time",
                 :x_axis_units                =>  "s",
                 :multiple_graphable_enabled  =>  false,
                 :draw_marks                  =>  false,
                 :connect_points              =>  true,
                 :autoscale_enabled           =>  false,
                 :ruler_enabled               =>  false,
                 :show_tare                   =>  false,
                 :single_value                =>  false


  default_value_for :probe_type, DISTANCE_PROBE_TYPE

  def self.display_name
    "Graph"
  end
  
  def update_from_otml_library_content
    olc = Hash.from_xml(otml_library_content)
    if ot_data_collector = olc['ot_data_collector']
      self.name = ot_data_collector['name']
      self.title = ot_data_collector['title']
      self.autoscale_enabled = ot_data_collector['auto_scale_enabled'] == 'true'
      if ot_data_axis = ot_data_collector['x_data_axis']['ot_data_axis']
        self.x_axis_label = ot_data_axis['label']
        self.x_axis_units = ot_data_axis['units']
        self.x_axis_min   = ot_data_axis['min']
        self.x_axis_max   = ot_data_axis['max']
      end
      if ot_data_axis = ot_data_collector['y_data_axis']['ot_data_axis']
        self.y_axis_label = ot_data_axis['label']
        self.y_axis_units = ot_data_axis['units']
        self.y_axis_min   = ot_data_axis['min']
        self.y_axis_max   = ot_data_axis['max']
      end
      if ot_data_graphable = ot_data_collector['source']['ot_data_graphable']
         self.connect_points = ot_data_graphable['connect_points']
         self.draw_marks = ot_data_graphable['draw_marks'] == 'true'
         self.connect_points = ot_data_graphable['connect_points']
         self.connect_points = ot_data_graphable['connect_points']
         self.connect_points = ot_data_graphable['connect_points']
         if ot_data_store = ot_data_graphable['data_store']['ot_data_store']
           if values = ot_data_store['values']
             self.data_store_values = values['float'].collect { |v| v.to_f }
           else
             self.data_store_values = []
           end
         end
      end
      self.save
    end
  end
end
