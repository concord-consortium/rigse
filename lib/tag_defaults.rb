module TagDefaults

  ##
  ## Called when a class is extended by this module
  ##
  def self.included(clazz)
    clazz.extend(ClassMethods)
    #clazz.class_eval do
      #after_save :update_available_tags
    #end
  end
  # class methods
  module ClassMethods
    def found_tags
      results = {}
      self.tag_types.each do |type|
        results[type] ||= []
        results[type] = results[type] +  self.tag_counts_on(type).map { |tc| tc.name }
        results[type] = results[type].uniq.sort
      end
      results
    end
    
    def default_tags
      {
        :units => "Crystals, Global Warming, Earthquakes, Water Cycle, Solar System, Weather".split(","),
        :grade_levels => "Elementary, Middle School, High School".split(","),
        :subject_areas => "Earth Science, Space Science, Life Science, Physics, Biology, Chemestry".split(",")
      }
    end

    def add_tag(scope,tag)
      unless self.default_tags[scope]
        self.default_tags[scope] = []
      end
      self.default_tags[scope] << tag.strip
      self.default_tags[scope].uniq!
      self.default_tags[scope].sort!
      self.default_tags[scope]
    end

    def available_tags(scope=nil)
      if scope
        if self.default_tags[scope] && self.default_tags[scope].size > 0
          return self.default_tags[scope].map { |i| i.strip}
        else
          return []
        end
      end
      return self.default_tags.values.flatten.uniq.map { |i| i.strip}
    end

    def find_by_bin(grade_level,subject_area)
      results = {}
      found = self.published.tagged_with(grade_level, :on => :grade_level).tagged_with(subject_area, :on => :subject_area)
      found.each do |act|
        act.units.each do |unit|
          results[unit] ||= []
          results[unit] << act
        end
      end
    end

    def list_bins(user=nil)
      grade_levels  = self.grade_level_counts
      subject_areas = self.subject_area_counts
      units = self.unit_counts.map { |u| u.name }
      results = []
      i = 0
      grade_levels.sort{|a,b| a.name <=> b.name}.each do |grade_level|
        subject_areas.sort{|a,b| a.name <=> b.name}.each_with_index do |subject,j|
          query = self.published
          query = query.tagged_with(grade_level.name, :on => :grade_levels)
          query = query.tagged_with(subject.name, :on => :subject_areas)
          unit_listing = units.map do |u| 
            u_query = query.tagged_with(u, :on => :units)
            { :name => u,
              :count => u_query.count,
              :activities => u_query
            }
          end
          unit_listing.reject! { |u| u[:count] < 1 }
          record = {
            :key          => "#{grade_level.name}#{subject.name}".gsub(/\s+/,"").downcase,
            :name         => "#{grade_level.name} #{subject.name}",
            :classes      => "unit-navigation level#{i+1}",
            :grade_level  => grade_level.name,
            :subject_area => subject.name,
            :query        => query,
            :units        => unit_listing,
            :count        => query.count
          }
          results << record
        end
        i = i + 1
      end # End Grade Levels
      
      # Add unpublished activities of the user:
      if user
        users = self.find(:all, :conditions => {:user_id => user.id});
        remainder = users.clone
        unit_listing = units.map do |u| 
          unit_activities = users.select { |a| a.unit_list && a.unit_list.include?(u) }
          remainder = remainder - unit_activities
          { 
            :name => u,
            :count => unit_activities.size,
            :activities => unit_activities
          }
        end

        if remainder.size > 0
          unit_record = {
            :name => "no assigned unit",
            :count => remainder.size,
            :activities => remainder
          }
          unit_listing << unit_record
        end

        record = {
          :key          => "users_own",
          :name         => "Your activities",
          :classes      => "unit-navigation level#{i+1}",
          :units        => unit_listing,
          :count        => users.size,
          :query        => users
        } 
        results << record 
      end
      results.each
      results.sort {|a,b| a[:key] <=> b[:key] }.uniq
    end
  
    #def keys(tags=self.tag_types)
      #results = []
      #_keys = tags.each do |t| 
        #counts = self.send("#{t.to_s.singularize}_counts".to_sym)
        #results << counts.map { |count| count.name }
      #end

      #_keys = results.compact
      ## [["1", "2", "3"], ["1", "2", "3", "4"], ["A","B"], ["a","b"]] 
        ##
        ##
      ## [ "1-1-A-a", "1-1-A-b", "1-1-B-a", "1-1-B-b", ]
      ## [1,2] [a,b] => [1-a, 1-b, 2-a, 2 -b]
      #index = _keys.size() -1
      #while index > 0
        #_keys[index-1].map! do |k|
          #_keys[index].flatten.map do |kk|
            #"#{k}-#{kk}"
          #end
        #end
        #_keys[index-1].flatten!
        #index = index - 1
      #end
      #_keys[0]
    #end
  end

  def random_tags
    self.grade_level_list = self.class.default_tags[:grade_levels].rand
    self.unit_list = self.class.default_tags[:units].rand
    self.subject_area_list = self.class.default_tags[:subject_areas].rand
  end

  def keys
    results = []
    self.grade_level_list.each do |grade|
      self.subject_area_list.each do |subject|
        self.unit_list.each do |unit|
          results << "#{grade} #{subject} #{unit}"
        end
      end
    end
    results
  end
end
