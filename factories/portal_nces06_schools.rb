Factory.define :portal_nces06_school, :class => Portal::Nces06School do |f|
  f.association :nces_district, :factory => :portal_nces06_district
end

