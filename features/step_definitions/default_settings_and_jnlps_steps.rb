Given /^the most basic default settings$/ do
  Factory.create(:admin_settings)
end

Given /^the database has been seeded$/ do
  ## see lib/mock_data/create_fake_data.rb and lib/mock_data/default_data.yml for more information...
end
#
# generator methods are in spec/helpers/controller_helper.rb
#
Given /^The default settings and jnlp resources exist$/ do
  generate_default_settings_and_jnlps_with_factories
end

Given /^The default settings and jnlp resources exist using mocks$/ do
  generate_default_settings_and_jnlps_with_mocks
end

Given /^The default settings and jnlp resources exist using factories$/ do
  generate_default_settings_and_jnlps_with_factories
end

def get_settings
  settings = Admin::Settings.default_settings
  unless settings
    generate_default_settings_and_jnlps_with_factories
    settings = Admin::Settings.default_settings
  end
  settings
end

def enabled_default_class(enable)
  settings = get_settings
  settings.allow_default_class = enable
  settings.save
end

def enable_security_questions(enable)
  settings = get_settings
  settings.use_student_security_questions = enable
  settings.save
end

def enable_student_consent(enable)
  settings = get_settings
  settings.require_user_consent = enable
  settings.save
end

def enable_include_external_activities(enable)
  settings = get_settings
  settings.include_external_activities = enable
  settings.save
end

Given /^the default settings has security questions enabled$/ do
  enable_security_questions(true)
end

Given /^the option to allow default classes is enabled$/ do
  enabled_default_class(true)
end

Given /^the option to allow default classes is disabled$/ do
  enabled_default_class(false)
end

Given /^the default settings has include external activities enabled$/ do
  enable_include_external_activities(true)
end

Given /^the default settings has student consent enabled$/ do
  enable_student_consent(true)
end

Then /^APP_CONFIG\[:([^\]]*)\] should be (true|false)$/ do |setting, value|
  APP_CONFIG[setting.to_sym].should == (value == 'true')
end

Then /^I should see the default district$/ do
  page.should have_xpath('//*', :text => APP_CONFIG[:site_district])
end
