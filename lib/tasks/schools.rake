namespace :app do
  namespace :schools do
  
    desc "WARNING: Delete all real districts, schools, teachers, students, offerings, etc except for the virtual site district and school"
    task :delete_all_real_schools => :environment do
      Portal::District.destroy_all("name <> '#{APP_CONFIG[:site_district]}'")
      Admin::Project.create_or_update_default_project_from_settings_yml
    end

  end
end