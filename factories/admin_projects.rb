Factory.define :admin_project, :class => Admin::Project do |f|
  name, url = Admin::Project.default_project_name_url
  
  f.user  { |p| Factory.next(:admin_user) } 
  f.name  name 
  f.url  url 
  f.states_and_provinces  APP_CONFIG[:states_and_provinces] 
  f.maven_jnlp_family { |p| Factory(:maven_jnlp_maven_jnlp_family) }
  f.maven_jnlp_server { |p| p.maven_jnlp_family.maven_jnlp_server  }
  f.jnlp_version_str  '0.1.0-20091013.161730' 
  f.snapshot_enabled  0 
  f.enable_default_users  APP_CONFIG[:enable_default_users]
end
