Factory.define :admin_project, :class => Admin::Project do |f|
  f.user  { |p| Factory.next(:admin_user) }
end
