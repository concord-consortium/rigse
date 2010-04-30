Factory.define :biologica_organism, :class => Embeddable::Biologica::Organism  do |f|
  f.name                  "Biologica Organism element"
  f.description           "description ..."
  f.sex                   1
  f.fatal_characteristics true
  f.association :world, :factory => :biologica_world
  
end
