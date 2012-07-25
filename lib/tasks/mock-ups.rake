
namespace :portal do
  namespace :dev do
    
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

    desc 'Load db with a large Class with 26 students and 10 investigations with 3 activities in each'
    task :load_large_class => :environment do
      require 'mock_data'

      # with an updated FactoryGirl this will be easier
      Dir.glob(File.join(Rails.root, 'factories/*.rb')).each { |f| require(f) }
      MockData.load_large_class
    end

    desc 'Load db with a mixed runnable type class'
    task :load_mixed_runnable_type_class => :environment do
      require 'mock_data'

      # with an updated FactoryGirl this will be easier
      Dir.glob(File.join(Rails.root, 'factories/*.rb')).each { |f| require(f) }
      MockData.load_mixed_runnable_type_class
    end
  end

end
