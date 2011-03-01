Factory.define :admin_project, :class => Admin::Project do |f|
  #name, url = Admin::Project.default_project_name_url

  #f.user  { |p| Factory.next(:admin_user) }
  #f.name  name
  #f.url  url
  #f.states_and_provinces  APP_CONFIG[:states_and_provinces]
  #f.snapshot_enabled  0
  #f.enable_default_users  APP_CONFIG[:enable_default_users]

  #if USING_JNLPS
    #server, family, version = Admin::Project.default_jnlp_info
    #begin
      #maven_jnlp_server = Factory.next(:default_maven_jnlp_maven_jnlp_server)
      #f.maven_jnlp_server maven_jnlp_server
      #f.maven_jnlp_family maven_jnlp_server.maven_jnlp_families.find_by_name(family)
    #rescue
    #end
    #f.jnlp_version_str version
  #end
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
  f.association :default_maven_jnlp_server, :factory => :maven_jnlp_maven_jnlp_server
end
