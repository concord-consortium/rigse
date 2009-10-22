Factory.sequence(:nces_school_name) { |n| "factory generated nces school ##{n}" }
  
Factory.define :portal_nces06_school, :class => Portal::Nces06School do |f|
  f.SCHNAM {Factory.next :nces_school_name}
  f.association :nces_district, :factory => :portal_nces06_district
end

