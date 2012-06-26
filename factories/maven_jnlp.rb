
#
# Singleton Factory Pattern for creating or returning the
# default MavenJnlp::MavenJnlpServer specified in app settings
#
Factory.sequence :default_maven_jnlp_maven_jnlp_server do |n|
  server, family, version = Admin::Project.default_jnlp_info
  attrs = { :host => server[:host], :path => server[:path] }
  unless mj_server = MavenJnlp::MavenJnlpServer.find(:first, :conditions => attrs)
    mj_server = Factory.create :maven_jnlp_maven_jnlp_server do |f|
      f.host server[:host]
      f.path server[:path]
      f.name server[:name]
    end
    mj_server.create_maven_jnlp_families
  end
  mj_server
end

Factory.define :maven_jnlp_maven_jnlp_server, :class => MavenJnlp::MavenJnlpServer do |f|
  server, family, version = Admin::Project.default_jnlp_info
  f.host server[:host]
  f.path server[:path]
  f.name server[:name]
end

Factory.define :admin_project_no_jnlps, :class => Admin::Project do |f|
  name, url = Admin::Project.default_project_name_url

  f.user  { |p| Factory.next(:admin_user) }
  f.name  name
  f.url  url
  f.opportunistic_installer true
  f.states_and_provinces  APP_CONFIG[:states_and_provinces] || []
  f.snapshot_enabled  0
  f.enable_default_users  APP_CONFIG[:enable_default_users]

end

Factory.define :admin_project, :parent => :admin_project_no_jnlps do |f|
  if USING_JNLPS
    server, family, version = Admin::Project.default_jnlp_info
    begin
      maven_jnlp_server = Factory.next(:default_maven_jnlp_maven_jnlp_server)
      f.maven_jnlp_server maven_jnlp_server
      f.maven_jnlp_family maven_jnlp_server.maven_jnlp_families.find_by_name(family)
    rescue
    end
    f.jnlp_version_str version
  end
end

# Factory.define :maven_jnlp_versioned_jnlp, :class => MavenJnlp::VersionedJnlp do |f|
#   f.name  'all-otrunk-snapshot-0.1.0-20091013.161730.jnlp'
#   f.main_class  'net.sf.sail.emf.launch.EMFLauncher3'
#   f.argument  'dummy'
#   f.offline_allowed  1
#   f.spec  '1.0+'
#   f.j2se_version  '1.5+'
#   f.max_heap_size  '128'
#   f.initial_heap_size  '32'
#   f.codebase  'http://jnlp.concord.org/dev'
#   f.href  'http://jnlp.concord.org/dev/org/concord/maven-jnlp/all-otrunk-snapshot/all-otrunk-snapshot-0.1.0-20091013.161730.jnlp'
#   f.title  'All OTrunk snapshot'
#   f.vendor  'Concord Consortium'
#   f.homepage  'index.html'
#   f.description  'Preview Basic Pas'
#   f.association :versioned_jnlp_url, :factory => :maven_jnlp_versioned_jnlp_url
# end
#
# Factory.define :maven_jnlp_versioned_jnlp_url, :class => MavenJnlp::VersionedJnlpUrl do |f|
#   server, family, version = Admin::Project.default_jnlp_info
#   f.path  '/dev/org/concord/maven-jnlp/all-otrunk-snapshot/all-otrunk-snapshot-0.1.0-20091013.161730.jnlp'
#   f.url  'http://jnlp.concord.org/dev/org/concord/maven-jnlp/all-otrunk-snapshot/all-otrunk-snapshot-0.1.0-20091013.161730.jnlp'
#   f.date_str  '20091013.161730'
#   f.version_str  version
#   f.association :maven_jnlp_family, :factory => :maven_jnlp_maven_jnlp_family
# end
#
# Factory.define :maven_jnlp_maven_jnlp_family, :class => MavenJnlp::MavenJnlpFamily do |f|
#   server, family, version = Admin::Project.default_jnlp_info
#   f.name family
#   f.snapshot_version version
#   f.url 'http://jnlp.concord.org/dev/org/concord/maven-jnlp/all-otrunk-snapshot/'
#   f.association :maven_jnlp_server, :factory => :maven_jnlp_maven_jnlp_server
# end
#
# Factory.define :maven_jnlp_maven_jnlp_server, :class => MavenJnlp::MavenJnlpServer do |f|
#   server, family, version = Admin::Project.default_jnlp_info
#   f.host server[:host]
#   f.path server[:path]
#   f.name server[:name]
# end
#
#
# Factory.define :maven_jnlp_jar, :class => MavenJnlp::Jar do |f|
# end
#
# Factory.define :maven_jnlp_native_library, :class => MavenJnlp::NativeLibrary do |f|
# end
#
# Factory.define :maven_jnlp_icon, :class => MavenJnlp::Icon do |f|
# end
#
# Factory.define :maven_jnlp_property, :class => MavenJnlp::Property do |f|
# end
#
