FactoryBot.define do
  factory :admin_project_link, class: Admin::ProjectLink do |f|
    f.name {'test project link'}
    f.href {'http://projectlink.com/'}
    f.link_id {'test'}
  end
end
