
# In order to run the user specs the encrypted passwords
# for the 'quentin' and 'aaron' users in spec/fixtures/users.yml
# need to be created with a hard-coded pepper used for testing.
#
# suppress_warnings is a Kernel extension ...
# See: config/initializers/00_core_extensions.rb
#
suppress_warnings {
  APP_CONFIG[:pepper] = 'sitekeyforrunningtests'
  Devise.setup do |config|
    config.pepper = APP_CONFIG[:pepper]
  end
}

# This modification allows stubing helper methods when using integrate views
# the template object isn't ready until the render method is called, so this code
# adds a hook to be run before render is run.

# this commented out because it was breaking cucumber spork runs
# this ApplicationController definition was loaded before the main one so then
# the application controller wasn't extending ActionController::Base
# class ApplicationController
#   def before_render; end
#   def render(options=nil, extra_options={}, &bloc)
#     before_render
#     super
#   end
# 
#   # any stub information is stored in the @mock_proxy variable of the object being stubbed, 
#   # so adding it here prevents the controller @mock_proxy from clobbering the view @mock_proxy 
#   # when rails copies the instance variables from the controller to view.  This copying happens
#   # sometime during the render method (after before_render)
#   @@protected_instance_variables = %w(@mock_proxy)
# end

#
# Factory Generators
#
def generate_default_project_and_jnlps_with_factories
  # if APP_CONFIG[:use_jnlps]
  #   @versioned_jnlp = Factory.create(:maven_jnlp_versioned_jnlp)
  #   @versioned_jnlp_url = @versioned_jnlp.versioned_jnlp_url
  #   @maven_jnlp_family = @versioned_jnlp_url.maven_jnlp_family
  #   @maven_jnlp_server = @maven_jnlp_family.maven_jnlp_server
  #   APP_CONFIG[:default_maven_jnlp][:version] = @maven_jnlp_family.snapshot_version
  #   @maven_jnlp_family.stub!(:newest_snapshot_version).and_return(@maven_jnlp_family.snapshot_version)
  # end
  if APP_CONFIG[:use_jnlps]
    server, family, version = JnlpAdaptor.default_jnlp_info
    @maven_jnlp_server = Factory.next(:default_maven_jnlp_maven_jnlp_server)
    @maven_jnlp_family = @maven_jnlp_server.maven_jnlp_families.find_by_name(family)
    if version == "snapshot"
      @versioned_jnlp_url = @maven_jnlp_family.snapshot_jnlp_url
    else
      @versioned_jnlp_url = @maven_jnlp_family.versioned_jnlp_urls.find_by_version_str(version)
    end
    @versioned_jnlp = @versioned_jnlp_url.versioned_jnlp
  end
  @admin_project = Factory.create(:admin_project)
  generate_default_school_resources_with_factories
end

def generate_default_school_resources_with_factories
  @portal_school = Factory(:portal_school)
  @portal_district = @portal_school.district
  @portal_grade_level = Factory(:portal_grade_level)
  @portal_grade = @portal_grade_level.grade
  @rigse_domain = Factory(:rigse_domain)
end

#
# Mock Generators
#

class ArrayOfVersionedJars < Array
  def find_all_by_os(os)
    find { |i| i.os == os } || []
  end
end

class ArrayOfVersionedJnlpUrls < Array
  def find_by_version_str(version_str)
    find { |i| i.version_str == version_str } || []
  end
end

def generate_jnlps_with_mocks
  server, family, version = JnlpAdaptor.default_jnlp_info

  @mock_maven_jnlp_icon ||= mock_model(MavenJnlp::Icon)

  @mock_maven_jnlp_jar = mock_model(MavenJnlp::Jar,
    :href => 'org/telscenter/sail-otrunk/sail-otrunk.jar',
    :name => 'sail-otrunk',
    :version_str => '0.1.0-20091009.031525-1075',
    :main => false,
    :os => nil)

  @versioned_jars = ArrayOfVersionedJars.new
  @versioned_jars[0] = @mock_maven_jnlp_jar

  @mock_maven_jnlp_property = mock_model(MavenJnlp::Property,
    :name => "maven.jnlp.version",
    :value => "all-otrunk-snapshot-0.1.0-20091013.161730")

  @mock_maven_jnlp_versioned_jnlp = mock_model(MavenJnlp::VersionedJnlp,
    :codebase => "http://jnlp.concord.org/dev",
    :j2se_version => '1.5+',
    :offline_allowed => true,
    :title => 'All OTrunk snapshot',
    :max_heap_size => "128",
    :vendor => 'Concord Consortium',
    :initial_heap_size => "32",
    :jars => @versioned_jars,
    :native_libraries => @versioned_jars,
    :properties => [@mock_maven_jnlp_property])

  @mock_maven_jnlp_versioned_jnlp_url = mock_model(MavenJnlp::VersionedJnlpUrl,
    :versioned_jnlp => @mock_maven_jnlp_versioned_jnlp,
    :version_str => version,
    :url => 'http://jnlp.concord.org/dev/org/concord/maven-jnlp/all-otrunk-snapshot/all-otrunk-snapshot-0.1.0-20070420.131610.jnlp')

  @versioned_jnlp_urls = ArrayOfVersionedJnlpUrls.new
  @versioned_jnlp_urls[0] = @mock_maven_jnlp_versioned_jnlp_url

  @mock_maven_jnlp_versioned_jnlp.stub!(:versioned_jnlp_url).and_return(@mock_maven_jnlp_versioned_jnlp_url)

  @mock_maven_jnlp_family = mock_model(MavenJnlp::MavenJnlpFamily,
    :name => family,
    :snapshot_version => version,
    :url => 'http://jnlp.concord.org/dev/org/concord/maven-jnlp/all-otrunk-snapshot/',
    :update_snapshot_jnlp_url => @mock_maven_jnlp_versioned_jnlp_url,
    :snapshot_jnlp_url => @mock_maven_jnlp_versioned_jnlp_url,
    :versioned_jnlp_urls => @versioned_jnlp_urls)

  @mock_maven_jnlp_versioned_jnlp_url.stub!(:maven_jnlp_family).and_return(@mock_maven_jnlp_family)

  @mock_gui_testing_maven_jnlp_family = mock_model(MavenJnlp::MavenJnlpFamily,
    :name => 'gui-testing',
    :snapshot_version => version,
    :url => 'http://jnlp.concord.org/dev/org/concord/maven-jnlp/all-otrunk-snapshot/',
    :update_snapshot_jnlp_url => @mock_maven_jnlp_versioned_jnlp_url,
    :snapshot_jnlp_url        => @mock_maven_jnlp_versioned_jnlp_url,
    :versioned_jnlp_urls => @versioned_jnlp_urls)

  @mock_maven_jnlp_server = mock_model( MavenJnlp::MavenJnlpServer,
    :host => server[:host],
    :path => server[:path],
    :name => server[:name],
    :maven_jnlp_family => @mock_maven_jnlp_family)

  @mock_maven_jnlp_family.stub!(:maven_jnlp_server).and_return(@mock_maven_jnlp_server)
end

# Generates a mock project and associated jnlp resources
def generate_default_project_and_jnlps_with_mocks
  server, family, version = JnlpAdaptor.default_jnlp_info
  generate_jnlps_with_mocks
  @mock_project = mock_model(Admin::Project,
    :active                         => true,
    :home_page_content              => nil,
    :use_student_security_questions => false,
    :using_custom_css?              => false,
    :use_bitmap_snapshots?          => false,
    :allow_adhoc_schools            => false,
    :allow_adhoc_schools?           => false,
    :require_user_consent?          => false,
    :allow_default_class            => false,
    :allow_default_class?           => false,
    :jnlp_cdn_hostname              => '',
    :enabled_bookmark_types         => []
  )

  Admin::Project.stub!(:default_project).and_return(@mock_project)
  mock_anonymous_user
  mock_admin_user
  mock_researcher_user
  
  # we have to do this because we can't easily stub helper methods so instead we are stubbing one level lower
  MavenJnlp::Jar.stub!(:find_all_by_os).and_return(@versioned_jars)
  JnlpAdaptor.stub(:maven_jnlp_server).and_return(@mock_maven_jnlp_server)
  JnlpAdaptor.stub(:maven_jnlp_family).and_return(@mock_maven_jnlp_family)
  mock_jnlp_adapter = JnlpAdaptor.new
  JnlpAdaptor.stub(:new).and_return(mock_jnlp_adapter)
  @mock_project
end

def generate_portal_resources_with_mocks
  @mock_school = mock_model(Portal::School)
  @mock_grade = mock_model(Portal::Grade)
  @mock_grade_level = mock_model(Portal::GradeLevel)
  @mock_external_user = mock_model(ExternalUser)
  # @mock_grade ||= mock_model(Portal::Grade, stubs)
  # @mock_grade_level ||= mock_model(Portal::GradeLevel, stubs)
end

def generate_otrunk_example_with_mocks
  @mock_otml_category ||= mock_model(OtrunkExample::OtmlCategory,
    :name => "BasicExamples"
  )

  @mock_otml_file ||= mock_model(OtrunkExample::OtmlFile,
    :content => nil,
    :path => "/Users/stephen/dev/test/rites/public/otrunk-examples/BasicExamples/basic_drawing.otml",
    :otml_category => @mock_otml_category
  )

  @mock_otrunk_import ||= mock_model(OtrunkExample::OtrunkImport,
    :classname => "OTSystem",
    :fq_classname => "org.concord.otrunk.OTSystem"
  )

  @mock_otrunk_view_entry ||= mock_model(OtrunkExample::OtrunkViewEntry,
    :classname => "OTDataDrawingToolView",
    :standard_edit_view => false,
    :standard_view => false,
    :fq_classname => "org.concord.datagraph.state.OTDataDrawingToolView",
    :edit_view => false,
    :otrunk_import => @mock_otrunk_import
  )
end

# >> User.anonymous
# => #<User id: 1, login: "anonymous", identity_url: nil, first_name: "Anonymous", last_name: "User",
#     email: "anonymous@concord.org", crypted_password: "c6dc287d3ec67838c8ad87760d1967099c101989",
#     salt: "c61a47e536e388ceb5e417fed9e74e1c890b2f2b", remember_token: nil, activation_code: nil,
#     state: "active", remember_token_expires_at: nil, activated_at: "2009-07-23 04:09:33",
#     deleted_at: nil, uuid: "d65bd9c4-264c-11de-ae9c-0014c2c34555", created_at: "2009-04-11 03:57:12",
#     updated_at: "2009-07-23 04:09:33", vendor_interface_id: 6, default_user: false, site_admin: false,
#     type: "User", external_user_domain_id: nil>
def mock_anonymous_user
  if @anonymous_user
    @anonymous_user
  else
    @anonymous_user = mock_model(User, :login => "anonymous", :name => "Anonymous User")
    @guest_role = mock_model(Role, :title => "guest")
    @anonymous_user.stub!(:id).and_return(1)
    @anonymous_user.stub!(:portal_teacher).and_return(nil)
    @anonymous_user.stub!(:portal_student).and_return(nil)
    @anonymous_user.stub!(:has_role?).and_return(nil)
    @anonymous_user.stub!(:has_role?).with("guest").and_return(true)
    @anonymous_user.stub!(:only_a_student?).and_return(false)
    @anonymous_user.stub!(:roles).and_return([@guest_role])
    @anonymous_user.stub!(:forget_me).and_return(nil)
    @anonymous_user.stub!(:anonymous?).and_return(true)
    @anonymous_user.stub!(:vendor_interface).and_return(mock_probe_vendor_interface)
    @anonymous_user.stub!(:extra_params).and_return({})
    @anonymous_user.stub!(:resource_pages).and_return([])
    @anonymous_user.stub!(:require_password_reset).and_return(false)
    User.stub!(:anonymous).and_return(@anonymous_user)
    User.stub!(:find_by_login).with('anonymous').and_return(@anonymous_user)
  end
end

def mock_admin_user
 if @admin_user
   @admin_user
 else
   @admin_user = mock_model(User, :login => "admin", :name => "Admin User")
   @admin_role = mock_model(Role, :title => "admin")
   @admin_user.stub!(:id).and_return(2)
   @admin_user.stub!(:portal_teacher).and_return(nil)
   @admin_user.stub!(:portal_student).and_return(nil)
   @admin_user.stub!(:has_role?).and_return(true)
   @admin_user.stub!(:has_role?).with("researcher").and_return(nil)
   @admin_user.stub!(:has_role?).with("teacher").and_return(nil)
   @admin_user.stub!(:has_role?).with("guest").and_return(nil)
   @admin_user.stub!(:has_role?).with("student").and_return(nil)
   @admin_user.stub!(:only_a_student?).and_return(false)
   @admin_user.stub!(:roles).and_return([@admin_role])
   @admin_user.stub!(:forget_me).and_return(nil)
   @admin_user.stub!(:anonymous?).and_return(false)
   @admin_user.stub!(:vendor_interface).and_return(mock_probe_vendor_interface)
   @admin_user.stub!(:resource_pages).and_return([])
   @admin_user.stub!(:extra_params).and_return({})
   @admin_user.stub!(:require_password_reset).and_return(false)
   User.stub!(:find_by_login).with('admin').and_return(@admin_user)
 end
end

def mock_researcher_user
 if @researcher_user
   @researcher_user
 else
   @researcher_user = mock_model(User, :login => "admin", :name => "Admin User")
   @researcher_role = mock_model(Role, :title => "researcher")
   @researcher_user.stub!(:id).and_return(2)
   @researcher_user.stub!(:portal_teacher).and_return(nil)
   @researcher_user.stub!(:portal_student).and_return(nil)
   @researcher_user.stub!(:has_role?).and_return(true)
   @researcher_user.stub!(:has_role?).with("admin").and_return(nil)
   @researcher_user.stub!(:has_role?).with("teacher").and_return(nil)
   @researcher_user.stub!(:has_role?).with("guest").and_return(nil)
   @researcher_user.stub!(:has_role?).with("student").and_return(nil)
   @researcher_user.stub!(:only_a_student?).and_return(false)
   @researcher_user.stub!(:roles).and_return([@researcher_role])
   @researcher_user.stub!(:forget_me).and_return(nil)
   @researcher_user.stub!(:anonymous?).and_return(false)
   @researcher_user.stub!(:vendor_interface).and_return(mock_probe_vendor_interface)
   @researcher_user.stub!(:extra_params).and_return({})
   User.stub!(:find_by_login).with('researcher').and_return(@researcher_user)
 end
end

def mock_probe_vendor_interface
  unless @probe_vendor_interface
    @probe_vendor_interface = mock_model(Probe::VendorInterface,
      :name => "Vernier Go! Link",
      :short_name => "vernier_goio",
      :communication_protocol => "usb",
      :device_id => 10
    )
    @probe_device_config = mock_model(Probe::DeviceConfig,
      :vendor_interface_id => @probe_vendor_interface,
      :config_string => "none"
    )
    @probe_vendor_interface.stub!(:device_configs).and_return([@probe_device_config])
  end
  @probe_vendor_interface
end

def login_admin(options = {})
  options[:admin] = true
  @logged_in_user = Factory.next :admin_user
  @controller.stub!(:current_visitor).and_return(@logged_in_user)
  @logged_in_user
end

def login_researcher(options = {})
  @logged_in_user = Factory.next :researcher_user
  @controller.stub!(:current_visitor).and_return(@logged_in_user)
  @logged_in_user
end

def login_author(options = {})
  @logged_in_user = Factory.next :researcher_user
  @controller.stub!(:current_visitor).and_return(@logged_in_user)
  @logged_in_user.add_role "author"
  @logged_in_user
end

def login_anonymous
  logout_user
end

def logout_user
  sign_out @logged_in_user unless @logged_in_user.nil?
  
  @logged_in_user = Factory.next :anonymous_user
  
  ApplicationController.any_instance.stub(:current_user).and_return(@logged_in_user)
  ApplicationController.any_instance.stub(:user_signed_in?).and_return(false)
  @controller.stub!(:current_visitor).and_return(@logged_in_user)
  @current_visitor = @logged_in_user
  @logged_in_user
end

def stub_current_user(user_sym)
  if user_sym.is_a?(User)
    @logged_in_user = user_sym
  else
    @logged_in_user = instance_variable_get("@#{user_sym.to_s}")
  end
  
  ApplicationController.any_instance.stub(:current_user).and_return(@logged_in_user)
  ApplicationController.any_instance.stub(:user_signed_in?).and_return(true)
  sign_in @logged_in_user
  @controller.stub!(:current_visitor).and_return(@logged_in_user)
  @current_visitor = @logged_in_user
  @logged_in_user
end

def will_paginate_params(opts = {})
  { :limit => opts[:limit] || 30, :offset => opts[:offset] || 0, :include=>opts[:include] || {} }
end

def xml_http_html_request(request_method, action, parameters = nil, session = nil, flash = nil)
  # set the request type so the response type is set tot html by rails
  # otherwise the testing code tries to handle the response as javascript
  request.env['HTTP_ACCEPT'] = Mime::HTML
  xml_http_request request_method, action, parameters, session, flash
end

