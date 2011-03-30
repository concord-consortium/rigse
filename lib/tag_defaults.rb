module TagDefaults

  ##
  ## Called when a class is extended by this module
  ##
  def self.included(clazz)
    ## add before_save hooks
    clazz.class_eval {
      @@default_tags = {
        :units => "Crystals, Global Warming, Earthquakes, Water Cycle, Solar System, Weather".split(","),
        :grade_levels => "Elementary, Middle School, High School".split(","),
        :subject_areas => "Earth Science, Space Science, Life Science, Physics, Biology, Chemestry".split(",")
      }
      
      # look through our records and update our defaults...
      self.tag_types.each do |type|
        if (@@default_tags[type])
          @@default_tags[type] = @@default_tags[type] | self.tag_counts_on(type).map { |c| c.name}
        else
          @@default_tags[type] = self.tag_counts_on(type).map { |c| c.name}
        end
      end
      
      # class methods
      def self.add_tag(scope,tag)
        unless @@default_tags[scope]
          @@default_tags[scope] = []
        end
        @@default_tags[scope] << tag.strip
        @@default_tags[scope].uniq!
      end

      def self.available_tags(scope)
        if scope
          if @@default_tags[scope] && @@default_tags[scope].size > 0
            return @@default_tags[scope].map { |i| i.strip}
          else
            return []
          end
        end
        return @@default_tags.values.flatten.uniq.map { |i| i.strip}
      end
    
      # after we are saved, add our tags.
      after_save :update_available_tags

    }
  end
  
  # check for new tags in this taggable thing
  def update_available_tags
    self.tag_types.each do |type|
      if (@@default_tags[type])
        @@default_tags[type] = @@default_tags[type] | self.tag_counts_on(type).map { |c| c.name}
      else
        @@default_tags[type] = self.tag_counts_on(type).map { |c| c.name}
      end
    end
  end

  
end
