FactoryBot.define do
  sequence :unique_slug do |n|
    "test-project-#{n}"
  end

  factory :project, class: Admin::Project do
    name { "test project" }
    landing_page_slug { generate(:unique_slug) }
  end
end
