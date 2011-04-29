module Embeddable::DataCollectorHelper
  def javascript_probetype_to_axis_label_hash(probetypes)
    out = "var probe_to_axis = Array();"
    probetypes.each do |pt|
      out << "probe_to_axis[#{pt.id}] = '#{pt.name}';"
    end
    return out
  end
  
  def javascript_probetype_to_units_hash(probetypes)
    out = "var probe_to_unit = Array();"
    probetypes.each do |pt|
      out << "probe_to_unit[#{pt.id}] = '#{pt.unit}';"
    end
    return out
  end
  
  def update_label_and_units_script(probetypes, label_field_id, unit_field_id)
    out = javascript_probetype_to_units_hash(probetypes)
    out << javascript_probetype_to_axis_label_hash(probetypes)
    out << "$('#{unit_field_id}').value = probe_to_unit[value]; $('#{label_field_id}').value = probe_to_axis[value];"
    return out
  end
end