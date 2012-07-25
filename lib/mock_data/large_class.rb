module MockData
  # this assumes the default users have been created
  def self.load_large_class
      clazz = Factory(:portal_clazz, :name => "Large Test Class", :teachers => [default_teacher])

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
      students << default_student
      default_student.clazzes << clazz

      offerings.each { |offering| 
        students.each{ |student|
          Factory(:portal_learner, :offering => offering, :student => student)
        }
      }
  end
end