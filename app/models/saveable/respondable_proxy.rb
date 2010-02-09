class Saveable::RespondableProxy
  
  attr_accessor :respondable, :embeddable_id, :embeddable, :learner_id, :learner
  
  def initialize(respondable)
    @respondable = respondable
    @respondable_class = @respondable.class

    @learner_id = @respondable.learner_id
    @learner = @respondable.learner

    @embeddable_association = @respondable_class.to_s.demodulize.underscore
    @embeddable_id = @respondable.send("#{@embeddable_association}_id")
    @embeddable = @respondable.send(@embeddable_association)

    page = @embeddable.page_elements.first.parent
    @page_name = page.name
    @page_position = page.position
    @page_id = page.id

    section = page.parent
    @section_name = section.name
    @section_position = section.position
    @section_id = section.id

    activity = section.parent
    @activity_name = activity.name
    @activity_position = activity.position
    @activity_id = activity.id

    investigation = activity.parent
    @investigation_name = investigation.name
    @investigation_id = investigation.id

    
  end
  
  def hash
    embeddable_id.hash
  end
  
  def eql?(other)
    embeddable_id == other.embeddable_id
  end
  
  def <=>(other)
    
  end
end