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

Given /^the option to allow default classes is enabled$/ do
  project = Admin::Project.default_project
  project.allow_default_class = true
  project.save
end
