# This file defines the minimum set of data needed for an Investigations instance to boot and run
print "Loading default data set... "
### Set up some default users and roles
vendor_interface = Factory(:vendor_interface)

anon_role = Factory.create(:role, :title => 'guest', :position => 0)
member_role = Factory.create(:role, :title => 'member', :position => 1)
admin_role = Factory.create(:role, :title => 'admin', :position => 2)

anon =  Factory.create(:user, {
  :login => 'anonymous', 
  :vendor_interface => vendor_interface
})

admin = Factory.create(:user, { 
  :login => 'admin', 
  :site_admin => 1, 
  :vendor_interface => vendor_interface
})

[anon,admin].each do |u|
  u.register
  u.activate
end
anon.roles << anon_role
admin.roles << member_role
admin.roles << admin_role

### Set up the default jnlp to use
### Will dynamically create the dependant models we need, by calling other factories as required.
### TODO: The factories should also use the 
versioned_jnlp = Factory(:maven_jnlp_versioned_jnlp)

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