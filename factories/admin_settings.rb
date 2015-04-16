Factory.define :admin_settings, :class => Admin::Settings do |f|
  f.user  { |p| Factory.next(:admin_user) }
  f.active true
  f.help_type "no help"
end
