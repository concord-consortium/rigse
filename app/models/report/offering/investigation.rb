class Report::Offering::Investigation
  
  attr_accessor :offering, :learners, :investigation, :activities, :embeddables, :saveables
  
  def initialize(offering)
    @offering = offering
    @learners = @offering.learners
    
    @investigation = offering.runnable
    @activities = @investigation.activities.collect { |activity| Report::Offering::Activity.new(self, @offering, activity) }
    
    # @activities = {}
    # 
    # @offering.learners.each { |learner| @learners[learner] = { :responses => nil } }
    # 
    # @saveables = @embeddables = {}
    # 
    # @investigation.saveable_types.each do |saveable_type|
    #   association = saveable_type.to_s.demodulize.underscore
    #   @saveables[saveable_type] = {
    #     :association => association,
    #     :items => @offering.send("#{association}s")
    #   }
    #   @embeddables[saveable_type] = {
    #     :association => association,
    #     :items => @investigation.send("#{association}s").collect
    #   }
    # end
    
      # responses = @offering.send("#{association}s")
      # respondables = responses.collect { |saveable| Saveable::RespondableProxy.new(saveable) }
      # 
      # @saveables[saveable_type] = {
      #   :association => association,
      #   :items => respondables
      # }
      # 
      # respondables.group_by do |respondable|
      #   @activities[activity] = responses.group_by do |section, responses|
      #     @activities[activity][section] = responses
      #   end
      # end
      # 
      # 
      # respondables.group_by(&:activity) do |activity, responses|
      #   @activities[activity] = responses.group_by(&:section) do |section, responses|
      #     @activities[activity][section] = responses
      #   end
      # end
      # 
      #   @learners[learner][:responses] = responses.group_by(&:activity_position) do |activity_position responses|
      # 
      # respondables.group_by(&:learner) do |learner, responses|
      #   @learners[learner][:responses] = responses.group_by(&:activity_position) do |activity_position responses|
      #     
      #     
     # end
  end

  def respondables(klazz=nil)
    @activities.collect { |activity_report| activity_report.respondables(klazz) }.flatten
  end

end