module MockData
  module MixedRunnableTypeClass
    # this assumes the default users have been created
    def self.load_mixed_runnable_type_class
        clazz = FactoryBot.create(:portal_clazz, :name => "Mixed Runnable Types", :teachers => [default_teacher])

        runnables = [
          FactoryBot.create(:external_activity, :name => "External Activity Sample"),
        ]

        offerings = runnables.map { |runnable|
          FactoryBot.create(:portal_offering, :clazz => clazz,
            :runnable => runnable
          )
        }

        # add the default student
        default_student.clazzes << clazz
        offerings.each { |offering|
          FactoryBot.create(:portal_learner, :offering => offering, :student => default_student)
        }

        clazz
    end
  end
end
