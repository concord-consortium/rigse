module MockData
  # this assumes the default users have been created
  def self.load_large_class
      clazz = FactoryBot.create(:portal_clazz, :name => "Large Test Class", :teachers => [default_teacher])

      offerings = ('A'..'J').map { |letter| 
        FactoryBot.create(:portal_offering, :clazz => clazz,
          :runnable => FactoryBot.create(:investigation,
            :name => "Investigation  #{letter}",
            :activities => (1 .. 3).map{|number| FactoryBot.create(:activity, :name => "Activity #{number}")}
          )
        )
      }
      students = ('A'..'Z').map { |letter| 
        FactoryBot.create(:portal_student,
          :user => FactoryBot.create(:user,
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
          FactoryBot.create(:portal_learner, :offering => offering, :student => student)
        }
      }
  end
end
