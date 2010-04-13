Factory.define :portal_district, :class => Portal::District do |f|
end

Factory.define :portal_nces06_district_district, :class => Portal::District do |f|
  f.association :nces_district, :factory =>:portal_nces06_district
end


