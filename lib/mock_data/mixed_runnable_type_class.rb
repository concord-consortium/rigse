module MockData
  # this assumes the default users have been created
  def self.load_mixed_runnable_type_class
      clazz = FactoryBot.create(:portal_clazz, :name => "Mixed Runnable Types", :teachers => [default_teacher])

      runnables = [
        FactoryBot.create(:investigation, :name => "Investigation Sample",
            :activities => (1 .. 3).map{|number| FactoryBot.create(:activity, :name => "Activity #{number}")}
          ),
        FactoryBot.create(:activity, :name => "Activity Sample",
            :sections => (1 .. 3).map{|number| FactoryBot.create(:section, :name => "Section #{number}")}
          ),
        # FactoryBot.create(:page, :name => "Page Sample"),
        FactoryBot.create(:external_activity, :name => "External Activity Sample"),
        FactoryBot.create(:external_activity, :name => "External Activity with internal reporting Sample",
          :template => FactoryBot.create(:activity, :name => "Backing Activity for External Activity")),
        FactoryBot.create(:external_activity, :name => "External Activity with external reporting Sample",
          :url => "/mock_html/test-external-activity.html")
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
