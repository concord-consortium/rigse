namespace :portal do
  namespace :dev do
    
    desc 'Load db with imaginary data for development use'
    task :load_mockup_data => :environment do
      MockupDataLoader.new.load
    end
    
    desc "erase data from portal resources"
    task :erase_portal_data => :environment do
      Portal::District.delete_all
      Portal::School.delete_all
      Portal::SchoolMembership.delete_all
      Portal::Semester.delete_all
      Portal::Subject.delete_all
      Portal::Course.delete_all
      Portal::GradeLevel.delete_all
      Portal::Clazz.delete_all
      Portal::Offering.delete_all
      Portal::Student.delete_all
      Portal::StudentClazz.delete_all
      Portal::Teacher.delete_all
      Portal::Learner.delete_all
      Portal::SdsConfig.delete_all
    end
  end
end
