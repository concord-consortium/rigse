class Saveable::SaveableStandin
  attr_accessor :embeddable
  # This "saveable" isn't really. Its faked.
  # include Saveable::Saveable
  def answered?
    false
  end
  
  def answer
    'not answered'
  end
  
  def answered_correctly?
    false
  end
  def initialize(_embeddable = nil)
    self.embeddable = _embeddable
  end
end
