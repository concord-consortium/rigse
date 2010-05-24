Factory.define :biologica_meiosis_view, :class => Embeddable::Biologica::MeiosisView do |f|
  f.association :father_organism, { :factory => :biologica_organism, :sex => 0 }
  f.association :mother_organism, { :factory => :biologica_organism, :sex => 1 }
end

