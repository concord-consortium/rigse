Given /^grade levels for classes is enabled$/ do
  project = Admin::Project.default_project
  project.enable_grade_levels = true
  project.save
end
