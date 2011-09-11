Given /^grade levels for classes is enabled$/ do
  project = Admin::Project.default_project
  project.enable_grade_levels = true
  project.save
end

Given /^member registration is (.+)$/ do |member_registration|
  project = Admin::Project.default_project
  state = case member_registration
  when 'enabled' then true
  when 'disabled' then false
  else Raise "member registration must be 'enabled' or 'disabled' in features"
  end
  project.enable_member_registration = state
  project.save
end