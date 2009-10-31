Factory.sequence(:nces_district_name) { |n| "factory generated nces district ##{n}" }
Factory.define :portal_nces06_district, :class => Portal::Nces06District do |f|
  f.NAME {Factory.next :nces_district_name}
end

