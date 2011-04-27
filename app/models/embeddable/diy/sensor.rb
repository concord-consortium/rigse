class Embeddable::Diy::Sensor < Embeddable::Embeddable
  FAIL_UPDATE_PREDICTION = "Unable to update prediction graph in Dit Sensor"
# AR Attributes:
# caption, has_prediction
  set_table_name "embeddable_diy_sensors"
  belongs_to :user
  belongs_to :prototype, :class_name => "Embeddable::DataCollector"
  validates_presence_of :prototype
  serialize :customizations, Hash
  belongs_to :prediction_graph_source,
    :class_name => "Embeddable::Diy::Sensor",
    :foreign_key => "prediction_graph_id"

  has_many :prediction_graph_destinations,
    :class_name => "Embeddable::Diy::Sensor",
    :foreign_key => "prediction_graph_id"
  
  # manually update the axis and other info
  # for the prediction graph
  after_save :update_prediction_graph 
  include Snapshotable

  class << self
    # fields we will accept customizations on
    def customizable_fields
      %w[
        y_axis_min
        y_axis_max
        x_axis_min
        x_axis_max
        multiple_graphable_enabled
        ].map{ |e| e.to_sym}
        # Other fields we might want to be able to override
        #x_axis_label
        #x_axis_units
        #y_axis_label
        #y_axis_units
        #draw_marks
        #connect_points
        #autoscale_enabled
        #ruler_enabled
        #show_tare
        #single_value
    end
    
    # should instances try and use customizations for this method?
    def custom_get?(method_sym)
      customizable_fields.detect{|e| method_sym.to_s =~ /^#{e.to_s}$/}      
    end

    # should instances try and use customizations for this method?
    def custom_set?(method_sym)
      customizable_fields.detect{|e| method_sym.to_s =~ /^#{e.to_s}=$/}      
    end
  end

  def respond_to?(method, *args, &block)
    return true if Embeddable::Diy::Sensor.custom_set?(method)
    return true if Embeddable::Diy::Sensor.custom_get?(method)
    return true if super
    return true if self.prototype.respond_to?(method, *args, &block)
  end

  def method_missing(method, *args, &block)
    if Embeddable::Diy::Sensor.custom_set?(method)
      # remove the trailing '=' from method_name to get field name
      field = method.to_s.chop.to_sym
      results = self.set(field, *args)
    elsif Embeddable::Diy::Sensor.custom_get?(method)
      field = method
      results = self.get(field)
    else
      begin
        # check active record first!
        results = super
      rescue(NoMethodError)
        results = self.prototype.send(method, *args, &block)
      end
      results
    end
  end

  def get(field)
    if (self.customizations && self.customizations.has_key?(field))
      return self.customizations[field]
    end
    return self.prototype.send(field)
  end
  
  def set(field,*args)
    self.customizations = {} if self.customizations.nil?
    self.customizations[field] = args[0]
  end

  # remove customizations for field
  def remove(field)
    self.customizations.delete(field) if self.customizations.has_key?
  end

  # remove all customizations
  def remove_customizations
    self.customizations = {}
  end
  
  def display_name
    "Sensor"
  end
  
  def update_prediction_graph
    prediction = self.prediction_graph_source
    return unless prediction
    copy_these = [:probe_type, :calibration, :y_axis_min, :y_axis_max, :x_axis_min, :x_axis_max, :x_axis_label, :x_axis_units, :y_axis_label, :y_axis_units, :draw_marks, :connect_points, :autoscale_enabled, :ruler_enabled, :show_tare]
    copy_these.each do |key|
      prediction.send("#{key.to_s}=".to_sym, self.send(key))
    end
    unless prediction.save
      Rails.logger.warn(Embeddable::Diy::Sensor::FAIL_UPDATE_PREDICTION)
      Rails.logger.warn(prediction.errors.full_messages)
    end
  end
end
