FactoryBot.define do
  factory :admin_settings, :class => Admin::Settings do |f|
    f.user {FactoryBot.generate(:admin_user)}
    f.active {true}
    f.help_type {"no help"}
  end
end
