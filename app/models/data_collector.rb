class DataCollector < ActiveRecord::Base
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  
  has_one :probe_type
  
  acts_as_replicatable
  
  include Changeable
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  def y_axis_title
    "#{self.y_axis_label} (#{self.y_axis_units})"
  end

  def x_axis_title
    "#{self.x_axis_label} (#{self.x_axis_units})"
  end

  default_value_for :name, "Data Collector Graph"
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
  
  #
  # If the y_axis_label matches an existing ProbeType#name
  # (which it should) and none of the following attributes
  # have been set earlier in the initialization:
  #
  #   y_axis_min, y_axis_max, y_axis_units
  #
  # Then set them to the default values for the probe_type.
  #
  def before_create
    if probe_type = ProbeType.find_by_name(self.y_axis_label)
      attrs = "#{self.y_axis_min}#{self.y_axis_max}#{self.y_axis_units}#{self.title}"
      if attrs.empty?
        self.y_axis_min = probe_type.min
        self.y_axis_max = probe_type.max
        self.y_axis_units = probe_type.unit
        self.probe_type_id = probe_type.id
        self.title = probe_type.name + ' Graph'
      end
    end
  end
end
