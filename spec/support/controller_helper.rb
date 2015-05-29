
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
def generate_default_settings_and_jnlps_with_factories
  @admin_settings = Factory.create(:admin_settings)
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

# Generates a mock settings and associated jnlp resources
def generate_default_settings_and_jnlps_with_mocks
  @mock_settings = mock_model(Admin::Settings,
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
    :default_project                => nil,
    :jnlp_cdn_hostname              => '',
    :enabled_bookmark_types         => []
  )

  Admin::Settings.stub!(:default_settings).and_return(@mock_settings)
  @mock_settings
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

def login_admin
  logged_in_user = Factory.next :admin_user
  sign_in logged_in_user
  logged_in_user
end

def login_manager
  logged_in_user = Factory.next :manager_user
  sign_in logged_in_user
  logged_in_user
end

def login_researcher
  logged_in_user = Factory.next :researcher_user
  sign_in logged_in_user
  logged_in_user
end

def login_author
  logged_in_user = Factory.next :author_user
  sign_in logged_in_user
  logged_in_user
end

def login_anonymous
  logout_user
end

def logout_user
  sign_out :user
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

def raw_post(action, params, body)
  @request.env['RAW_POST_DATA'] = body
  response = post(action, params)
  @request.env.delete('RAW_POST_DATA')
  response
end
