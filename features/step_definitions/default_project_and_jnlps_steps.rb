Given /^The most basic default project$/ do
  Factory.create(:admin_project_no_jnlps)
end

#
# generator methods are in spec/helpers/controller_helper.rb
#
Given /^The default project and jnlp resources exist$/ do
  generate_default_project_and_jnlps_with_factories
end

Given /^The default project and jnlp resources exist using mocks$/ do
  generate_default_project_and_jnlps_with_mocks
end

Given /^The default project and jnlp resources exist using factories$/ do
  generate_default_project_and_jnlps_with_factories
end

def enabled_default_class(enable)
  project = Admin::Project.default_project
  unless project
    generate_default_project_and_jnlps_with_factories
    project = Admin::Project.default_project
  end
  project.allow_default_class = enable
  project.save
end

Given /^the option to allow default classes is enabled$/ do
  enabled_default_class(true)
end

Given /^the option to allow default classes is disabled$/ do
  enabled_default_class(false)
end
