Factory.define :biologica_static_organism, :class => Embeddable::Biologica::StaticOrganism do |f|
  f.association :organism, :factory => :biologica_organism
end

