module ProbeTypesHelper
  def probe_types(material)
    if material.respond_to? 'data_collectors'
      material.data_collectors.map { |c| c.probe_type }.uniq
    else
      []
    end
  end
end
