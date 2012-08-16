module MockData
  # this assumes the default users have been created
  def self.load_mixed_runnable_type_class
      clazz = Factory(:portal_clazz, :name => "Mixed Runnable Types", :teachers => [default_teacher])

      runnables = [
        Factory(:investigation, :name => "Investigation Sample",
            :activities => (1 .. 3).map{|number| Factory(:activity, :name => "Activity #{number}")}
          ),
        Factory(:activity, :name => "Activity Sample",
            :sections => (1 .. 3).map{|number| Factory(:section, :name => "Section #{number}")}
          ),
        Factory(:page, :name => "Page Sample"),
        Factory(:external_activity, :name => "External Activity Sample"),
        Factory(:external_activity, :name => "External Activity with internal reporting Sample",
          :template => Factory(:activity, :name => "Backing Activity for External Activity")),
        Factory(:external_activity, :name => "External Activity with external reporting Sample",
          :url => "/mock_html/test-external-activity.html",
          :report_url => "/mock_html/test-external-report.html"),

        Factory(:resource_page, :name => "Resource Page Sample")
      ]

      offerings = runnables.map { |runnable| 
        Factory(:portal_offering, :clazz => clazz,
          :runnable => runnable
        )
      }

      # add the default student
      default_student.clazzes << clazz
      offerings.each { |offering| 
        Factory(:portal_learner, :offering => offering, :student => default_student)
      }

      clazz
  end
end