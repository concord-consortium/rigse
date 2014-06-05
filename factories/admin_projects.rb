Factory.define :admin_project, :class => Admin::Project do |f|
  f.user  { |p| Factory.next(:admin_user) }
  f.active true
  f.help_type "no help"
end
