class Embeddable::Diy::Sensor < Embeddable::DataCollector
  include Snapshotable
  UninheritableAttributes = 
    [
      :id,
      :user_id,
      :uuid,
      :title,
      :multiple_graphable_enabled,
      :created_at,
      :updated_at,
      :prediction_graph_id,
      :is_prototype
    ]

  def self.create(attr)
    proto = attr.delete(:prototype)
    result = super(attr)  
    result.set_prototype(proto)
    result.save
    result
  end
 
  def set_prototype(data_collector_proto)
    atr = data_collector_proto.attributes.reject {|k,v| UninheritableAttributes.include?(k.to_sym) }
    self.update_attributes(atr)
  end

  def display_name
    "Sensor"
  end
end
