# This file defines the minimum set of data needed for an Investigations instance to boot and run
print "Loading default data set... "
### Set up some default users and roles
vendor_interface = Factory.create(:vendor_interface, 
{ :user_id => 2, 
  :name => 'Vernier Go! Link', 
  :short_name => 'vernier_goio', 
  :communication_protocol => 'usb', 
  :image => 'SensorImages/VernierGoLink_sm.png', 
  :device_id => 10, 
  :description => 'The Vernier Go!Link is a USB interface with one sensor port. It works with Vernier analog sensors. The Go!Temp and Go!Motion sensors have Go!Link interfaces integrated into the sensor.'
})
device_config = Factory.create(:device_config,
{
  :user_id => 2,
  :vendor_interface_id => vendor_interface.id,
  :config_string => 'none'
})

anon_role = Factory.create(:role, :title => 'guest', :position => 0)
member_role = Factory.create(:role, :title => 'member', :position => 1)
admin_role = Factory.create(:role, :title => 'admin', :position => 2)

anon =  Factory.create(:user, 
{ :login => 'anonymous', 
  :first_name => 'Anonymous', 
  :last_name => 'User', 
  :email => 'anonymous@concord.org', 
  :password => 'password', 
  :password_confirmation => 'password', 
  :vendor_interface_id => vendor_interface.id
})
admin = Factory.create(:user, 
{ :login => 'admin', 
  :first_name => 'Admin', 
  :last_name => 'User', 
  :email => 'admin@concord.org', 
  :password => 'password', 
  :password_confirmation => 'password', 
  :site_admin => 1, 
  :vendor_interface_id => vendor_interface.id
})

[anon,admin].each do |u|
  u.register
  u.activate
end
anon.roles << anon_role
admin.roles << member_role
admin.roles << admin_role

### Set up the default jnlp to use
maven_jnlp_server = Factory.create(:maven_jnlp_maven_jnlp_server, 
{ :host => 'http://jnlp.concord.org', 
  :path => '/dev/org/concord/maven-jnlp/', 
  :name => 'concord'
})
maven_jnlp_family = Factory.create(:maven_jnlp_maven_jnlp_family, 
{ :maven_jnlp_server_id => maven_jnlp_server.id, 
  :name => 'all-otrunk-snapshot', 
  :snapshot_version => '0.1.0-20091013.161730', 
  :url => 'http://jnlp.concord.org/dev/org/concord/maven-jnlp/all-otrunk-snapshot/'
})
versioned_jnlp_url = Factory.create(:maven_jnlp_versioned_jnlp_url, 
{ :maven_jnlp_family_id => maven_jnlp_family.id,
  :path => '/dev/org/concord/maven-jnlp/all-otrunk-snapshot/all-otrunk-snapshot-0.1.0-20091013.161730.jnlp',
  :url => 'http://jnlp.concord.org/dev/org/concord/maven-jnlp/all-otrunk-snapshot/all-otrunk-snapshot-0.1.0-20091013.161730.jnlp',
  :version_str => '0.1.0-20091013.161730',
  :date_str => '20091013.161730'
})
versioned_jnlp = Factory.create(:maven_jnlp_versioned_jnlp,
{ :versioned_jnlp_url_id => versioned_jnlp_url.id,
  :name => 'all-otrunk-snapshot-0.1.0-20091013.161730.jnlp',
  :main_class => 'net.sf.sail.emf.launch.EMFLauncher3',
  :argument => 'dummy',
  :offline_allowed => 1,
  :spec => '1.0+',
  :j2se_version => '1.5+',
  :max_heap_size => '128',
  :initial_heap_size => '32',
  :codebase => 'http://jnlp.concord.org/dev',
  :href => 'http://jnlp.concord.org/dev/org/concord/maven-jnlp/all-otrunk-snapshot/all-otrunk-snapshot-0.1.0-20091013.161730.jnlp',
  :title => 'All OTrunk snapshot',
  :vendor => 'Concord Consortium',
  :homepage => 'index.html',
  :description => 'Preview Basic Pas'
})

### Set up the Admin Config
# Factory.create(:admin_project, 
#{ :user_id => 2, 
#  :name => 'RITES Investigations', 
#  :url => 'http://localhost:3000/', 
#  :states_and_provinces => '---\n- MA\n- RI\n', 
#  :maven_jnlp_server_id => 1, 
#  :maven_jnlp_family_id => 1, 
#  :jnlp_version_str => '0.1.0-20091013.161730', 
#  :snapshot_enabled => 0, 
#  :enable_default_users => 1
#})
Admin::Project.create_or_update_default_project_from_settings_yml

puts "done."