Factory.define :biologica_chromosome, :class => Embeddable::Biologica::Chromosome do |f|
  f.association :organism, :factory => :biologica_organism
end

