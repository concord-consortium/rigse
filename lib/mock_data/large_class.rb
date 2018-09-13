module MockData
  # this assumes the default users have been created
  def self.load_large_class
      clazz = FactoryGirl.create(:portal_clazz, :name => "Large Test Class", :teachers => [default_teacher])

      offerings = ('A'..'J').map { |letter| 
        FactoryGirl.create(:portal_offering, :clazz => clazz,
          :runnable => FactoryGirl.create(:investigation,
            :name => "Investigation  #{letter}",
            :activities => (1 .. 3).map{|number| FactoryGirl.create(:activity, :name => "Activity #{number}")}
          )
        )
      }
      students = ('A'..'Z').map { |letter| 
        FactoryGirl.create(:portal_student,
          :user => FactoryGirl.create(:user,
            :first_name => "Student", 
            :last_name => letter),
          :clazzes => [clazz]
        )
      }

      # add the default student
      students << default_student
      default_student.clazzes << clazz

      offerings.each { |offering| 
        students.each{ |student|
          FactoryGirl.create(:portal_learner, :offering => offering, :student => student)
        }
      }
  end
end
