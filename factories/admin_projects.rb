Factory.define :admin_project, :class => Admin::Project do |f|
  f.name "RITES"
  f.url "http://localhost:3000"
  f.association :admin_project_settings
  f.default_project true
end

Factory.define :admin_project_settings, :class => Admin::ProjectSettings do |f|
  f.top_level_container_name "investigations"
  f.site_name "RITES"
  f.theme "xproject"
  f.default_maven_jnlp_version "0.1.0-20090724.190238"
  f.states_and_provinces ["RI"]
  f.site_url "http://localhost:3000"
  f.runnables_use "otrunk-jnlp"
  f.site_district "RITES Investigations-district"
  f.site_school "RITES Investigations-school"
  f.use_gse "true"
  f.enable_default_users "true"
  f.active_school_levels ["2", "3", "4"]
  f.active_grades ["6", "7", "8", "9", "10", "11", "12"]
  f.tiny_mce_config {{:buttons1 => ["bold,italic,underline", "sup,sub", "bullist,numlist", "link,image", "pastext, pasteword,selectall", "justifyleft,justifycenter,justifyright", "code"]}}
  f.association :default_maven_jnlp_server, :factory => :maven_jnlp_maven_jnlp_server
  f.association :default_maven_jnlp_family, :factory => :maven_jnlp_maven_jnlp_family
  f.association :default_admin_user, :factory => :default_admin_user
end
