Factory.define :admin_project, :class => Admin::Project do |f|
  f.user  { |p| Factory.next(:admin_user) } 
  f.name  'RITES Investigations' 
  f.url  'http://localhost:3000/' 
  f.states_and_provinces  %w{RI MA} 
  f.maven_jnlp_family { |p| Factory(:maven_jnlp_maven_jnlp_family) }
  f.maven_jnlp_server { |p| p.maven_jnlp_family.maven_jnlp_server  }
  f.jnlp_version_str  '0.1.0-20091013.161730' 
  f.snapshot_enabled  0 
  f.enable_default_users  1
end
