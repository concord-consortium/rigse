module ProbeTypesHelper
  def probe_types(material)
    material.data_collectors.map { |c| c.probe_type }.uniq
  end
end
