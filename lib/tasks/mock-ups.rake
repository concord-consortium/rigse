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

    desc 'Load db with a large Class with 26 students and 10 investigations with 3 activities in each'
    task :load_large_class => :environment do
      Dir.glob(File.join(Rails.root, 'factories/*.rb')).each { |f| require(f) }

      # try to use the default teacher
      teacher_user = User.find_by_login 'teacher'
      teacher = teacher_user.portal_teacher
      clazz = Factory(:portal_clazz, :name => "Large Test Class", :teachers => [teacher])

      offerings = ('A'..'J').map { |letter| 
        Factory(:portal_offering, :clazz => clazz,
          :runnable => Factory(:investigation,
            :name => "Investigation  #{letter}",
            :activities => (1 .. 3).map{|number| Factory(:activity, :name => "Activity #{number}")}
          )
        )
      }
      students = ('A'..'Z').map { |letter| 
        Factory(:portal_student, 
          :user => Factory(:user,  
            :first_name => "Student", 
            :last_name => letter),
          :clazzes => [clazz]
        )
      }

      offerings.each { |offering| 
        students.each{ |student|
          Factory(:portal_learner, :offering => offering, :student => student)
        }
      }
    end
  end
end
