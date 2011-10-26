class Itsi::Activity < Itsi::Itsi
  set_table_name "itsidiy_activities"
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  belongs_to :user, :class_name => "Itsi::User"
  belongs_to :probe_type, :class_name => "Probe::ProbeType"
  belongs_to :model, :class_name => "Itsi::Model"
  
  belongs_to :second_probe_type, :class_name => "Probe::ProbeType", :foreign_key => :collectdata2_probetype_id
  belongs_to :second_model, :class_name => "Itsi::Model", :foreign_key => :collectdata2_model_id
  belongs_to :third_probe_type, :class_name => "Probe::ProbeType", :foreign_key => :collectdata3_probetype_id
  belongs_to :third_model, :class_name => "Itsi::Model", :foreign_key => :collectdata3_model_id
  belongs_to :fourth_probe_type, :class_name => "Probe::ProbeType", :foreign_key => :further_probetype_id
  belongs_to :fourth_model, :class_name => "Itsi::Model", :foreign_key => :further_model_id
  
  # This method allows an easy production of an array of strings
  # representing all the different and unique interactive components
  # used in an activity or a collection of activities. 
  # For example: 
  # activities = Activity.all
  # [:models, :probes].collect {|k| activities.collect {|a| a.interactive_components[k] } }.flatten.uniq
  # => ["Molecular Workbench", "PhET Circuit Construction Kit", "NetLogo", "PhET Wave Interference Model", 
  #     "Temperature", "Light", "Force (5N)", "Motion", "Voltage", "Relative Humidity", "Raw Voltage"]
  def interactive_components
    p, m = [], []
    # collect probe_type names
    begin
      if collectdata_probe_active then p << probe_type.name end
      if collectdata2_probe_active then p << second_probe_type.name end
      if collectdata3_probe_active then p << third_probe_type.name end
      # collect model_type names
      if collectdata_model_active && model then m << model.model_type.name end
      if collectdata2_model_active && second_model then m << second_model.model_type.name end
      if collectdata3_model_active && third_model then m << third_model.model_type.name end
      if further_model_active && fourth_model then m << fourth_model.model_type.name end
    rescue NoMethodError => e
      logger.warn("Exception: #{e}\n\n#{e.backtrace.join("\n")}")
    end
    {:probes => p.uniq, :models => m.uniq }
  end
  
  def contains_active_model(model_object)
    m = []
    if collectdata_model_active && model == model_object then m << model end
    if collectdata2_model_active && second_model == model_object then m << second_model end
    if collectdata3_model_active then m << third_model.model_type.name end
    if further_model_active then m << fourth_model.model_type.name end
    m.length > 0
  end

end
