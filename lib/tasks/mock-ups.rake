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

      # add the default student
      student_user = User.find_by_login 'student'
      default_student = student_user.portal_student
      students << default_student
      default_student.clazzes << clazz

      offerings.each { |offering| 
        students.each{ |student|
          Factory(:portal_learner, :offering => offering, :student => student)
        }
      }
    end

    desc 'Load db with a mixed runnable type class'
    task :load_mixed_runnable_type_class => :environment do
      Dir.glob(File.join(Rails.root, 'factories/*.rb')).each { |f| require(f) }

      # try to use the default teacher
      teacher_user = User.find_by_login 'teacher'
      teacher = teacher_user.portal_teacher
      clazz = Factory(:portal_clazz, :name => "Mixed Runnable Types", :teachers => [teacher])

      runnables = [
        Factory(:investigation, :name => "Investigation Sample",
            :activities => (1 .. 3).map{|number| Factory(:activity, :name => "Activity #{number}")}
          ),
        Factory(:activity, :name => "Activity Sample",
            :sections => (1 .. 3).map{|number| Factory(:section, :name => "Section #{number}")}
          ),
        Factory(:page, :name => "Page Sample"),
        Factory(:external_activity, :name => "External Activity Sample"),
        Factory(:resource_page, :name => "External Activity Sample")
      ]

      offerings = runnables.map { |runnable| 
        Factory(:portal_offering, :clazz => clazz,
          :runnable => runnable
        )
      }

      # add the default student
      student_user = User.find_by_login 'student'
      student = student_user.portal_student
      student.clazzes << clazz

      offerings.each { |offering| 
        Factory(:portal_learner, :offering => offering, :student => student)
      }
    end
  end

end
