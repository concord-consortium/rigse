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
  unless project
    generate_default_project_and_jnlps_with_factories
    project = Admin::Project.default_project
  end
  project.allow_default_class = true
  project.save
end

Given /^the option to allow default classes is disabled$/ do
  project = Admin::Project.default_project
  unless project
    generate_default_project_and_jnlps_with_factories
    project = Admin::Project.default_project
  end
  project.allow_default_class = false
  project.save
end
