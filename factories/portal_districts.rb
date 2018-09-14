FactoryGirl.define do
  factory :portal_district, :class => Portal::District do |f|
    f.name(APP_CONFIG[:site_district] || "Test District")
  end
end

FactoryGirl.define do
  factory :portal_nces06_district_district, :class => Portal::District do |f|
    f.association :nces_district, :factory => :portal_nces06_district
  end
end
