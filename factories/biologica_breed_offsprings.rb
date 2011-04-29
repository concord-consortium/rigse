Factory.define :biologica_breed_offspring, :class => Embeddable::Biologica::BreedOffspring do |f|
  f.association :father_organism, { :factory => :biologica_organism, :sex => 0 }
  f.association :mother_organism, { :factory => :biologica_organism, :sex => 1 }
end

