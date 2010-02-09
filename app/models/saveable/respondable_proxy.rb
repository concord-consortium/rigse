class Saveable::RespondableProxy
  
  attr_accessor :respondable, :respondable_class, :answered, :embeddable_id, :embeddable, :learner_id, :learner
  
  def initialize(respondable)
    @respondable = respondable
    @respondable_class = @respondable.class
    if @respondable_class.name[/^Saveable::/]
      @answered = true
      @learner_id = @respondable.learner_id
      @learner = @respondable.learner
      @embeddable_association = @respondable_class.to_s.demodulize.underscore
      @embeddable_id = @respondable.send("#{@embeddable_association}_id")
      @embeddable = @respondable.send(@embeddable_association)
    else
      @answered = false
      @embeddable = @respondable
      @embeddable_id = @embeddable.id
      @learner_id = nil
      @learner = nil
    end
  end
  
  def hash
    embeddable_id.hash
  end
  
  def eql?(other)
    embeddable_id == other.embeddable_id
  end

end