module TagDefaults

  ##
  ## Called when a class is extended by this module
  ##
  def self.included(clazz)
    ## add before_save hooks
    clazz.class_eval {
      @@default_tags = {
        :units => "Crystals, Global Warming, Earthquakes, Water Cycle, Solar System, Weather".split(","),
        :grade_levels => "Elementary, Middle School, HighSchool".split(","),
        :subject_areas => "Earth Science, Space Science, Life Science, Physics, Biology, Chemestry".split(",")
      }
      
      def self.add_tag(scope,tag)
        unless @@default_tags[scope]
          @@default_tags[scope] = []
        end
        @@default_tags[scope] << tag
        @@default_tags[scope].uniq!
      end

      def self.available_tags(scope)
        if scope
          return @@default_tags[scope].map { |i| i.strip}
        end
        return @@default_tags.values.flatten.uniq.map { |i| i.strip}
      end
    }
  end
  
  
end
