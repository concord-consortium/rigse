class Report::Offering::Investigation
  
  attr_accessor :offering, :investigation, :activities, :embeddables, :saveables, :learners
  
  def initialize(offering)
    @offering = offering
    @investigation = offering.runnable
    
    @activities = {}

    @learners = {}
    
    @offering.learners.each { |learner| @learners[learner] = { :responses => nil } }

    @saveables = @embeddables = {}
    @investigation.saveable_types.each do |saveable_type|
      association = saveable_type.to_s.demodulize.underscore

      @embeddables[saveable_type] = {
        :association => association,
        :items => @investigation.send("#{association}s").collect
      }
      
      responses = @offering.send("#{association}s")
      respondables = responses.collect { |saveable| Saveable::RespondableProxy.new(saveable) }

      @saveables[saveable_type] = {
        :association => association,
        :items => respondables
      }

      respondables.group_by(&:activity) do |activity, responses|
        @activities[activity] = responses.group_by(&:section) do |section, responses|
          @activities[activity][section] = responses
        end
      end
      # 
      #   @learners[learner][:responses] = responses.group_by(&:activity_position) do |activity_position responses|
      # 
      # respondables.group_by(&:learner) do |learner, responses|
      #   @learners[learner][:responses] = responses.group_by(&:activity_position) do |activity_position responses|
      #     
      #     
     end
  end

end