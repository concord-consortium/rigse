module MockData
  # this assumes the default users have been created
  def self.load_mixed_runnable_type_class
      clazz = FactoryGirl.create(:portal_clazz, :name => "Mixed Runnable Types", :teachers => [default_teacher])

      runnables = [
        FactoryGirl.create(:investigation, :name => "Investigation Sample",
            :activities => (1 .. 3).map{|number| FactoryGirl.create(:activity, :name => "Activity #{number}")}
          ),
        FactoryGirl.create(:activity, :name => "Activity Sample",
            :sections => (1 .. 3).map{|number| FactoryGirl.create(:section, :name => "Section #{number}")}
          ),
        # FactoryGirl.create(:page, :name => "Page Sample"),
        FactoryGirl.create(:external_activity, :name => "External Activity Sample"),
        FactoryGirl.create(:external_activity, :name => "External Activity with internal reporting Sample",
          :template => FactoryGirl.create(:activity, :name => "Backing Activity for External Activity")),
        FactoryGirl.create(:external_activity, :name => "External Activity with external reporting Sample",
          :url => "/mock_html/test-external-activity.html")
      ]

      offerings = runnables.map { |runnable| 
        FactoryGirl.create(:portal_offering, :clazz => clazz,
          :runnable => runnable
        )
      }

      # add the default student
      default_student.clazzes << clazz
      offerings.each { |offering| 
        FactoryGirl.create(:portal_learner, :offering => offering, :student => default_student)
      }

      clazz
  end
end
