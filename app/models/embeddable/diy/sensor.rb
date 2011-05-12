class Embeddable::Diy::Sensor < Embeddable::Embeddable
# AR Attributes
# caption, has_prediction
  set_table_name "embeddable_diy_sensors"
  belongs_to :user
  belongs_to :prototype, :class_name => "Embeddable::DataCollector"
  validates_presence_of :prototype
  belongs_to :prediction_graph_source,
    :class_name => "Embeddable::Diy::Sensor",
    :foreign_key => "prediction_graph_id"

  has_many :prediction_graph_destinations,
    :class_name => "Embeddable::Diy::Sensor",
    :foreign_key => "prediction_graph_id"
  
  include Snapshotable
  uncloneable_attributes :prediction_graph_id, :prediction_graph_source
  def self.display_name
    "Sensor"
  end

  # not sure about this one
  def display_name
    if self.graph_type == "Prediction" 
      return "Prediction Graph"
    end
    return "Sensor"
  end

  # we specify this ourself since some of the code is going to use us to generate an refering id
  #  and other parts of the code will use our data_collector
  def ot_dom_id
    "diy_sensor_#{id}"
  end

  def data_collector
    return @data_collector if @data_collector
    if graph_type == "Prediction"
      delegate = prediction_graph_destinations.first.data_collector
    else
      delegate = prototype
    end    
    @data_collector = DataCollector.new(self, delegate)
  end

  # this might be cleaner if we could extend or clone Embeddable::DataCollector somehow
  class DataCollector
    def initialize(sensor, delegate)
      @sensor = sensor
      @delegate = delegate
    end

    # use the id of the sensor object not the prototype
    delegate :id, :user, :user_id, :uuid, :multiple_graphable_enabled, :graph_type, :ot_dom_id, :to => :@sensor

    def save
      raise "This is a dynamic 'view' of a DataCollector and shouldn't be saved"
    end
    
    def save! 
      save 
    end

    def prediction_graph_source
      prediction = @sensor.prediction_graph_source
      # FIXME this needs to figure out if the found page_elements will be rendered when this data_collector is rendered
      #  because in theory it could be rendered independently then this isn't an easy problem to solve
      if prediction and prediction.page_elements.any? { |pe| pe.is_enabled?}
        @sensor.prediction_graph_source.data_collector 
      else
        nil
      end
    end

    def prediction_graph_destinations
      @sensor.prediction_graph_destinations.map{|target| target.data_collector}
    end

    # we only respond to methods defined on the Embeddable::DataCollector
    def respond_to?(method, *args, &block)
      return true if super
      @delegate.respond_to?(method, *args, &block)
    end

    def method_missing(method, *args, &block)
      @delegate.send(method, *args, &block)
    end
  end

end
