FactoryBot.define do
  factory :project, class: Admin::Project do |f|
    f.name 'test project'
  end
end
