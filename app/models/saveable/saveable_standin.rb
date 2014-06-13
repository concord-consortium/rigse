class Saveable::SaveableStandin
  attr_accessor :embeddable
  # This "saveable" isn't really. Its faked.
  # include Saveable::Saveable

  def initialize(_embeddable = nil)
    self.embeddable = _embeddable
  end

  def answered?
    false
  end

  def answer
    if embeddable.is_a? Embeddable::MultipleChoice
      [{:answer => 'not answered'}]
    else
      'not answered'
    end
  end

  def submitted_answer
    if embeddable.is_a? Embeddable::MultipleChoice
      [{:answer => 'not answered'}]
    else
      'not answered'
    end
  end

  def answered_correctly?
    false
  end

  def submitted?
    false
  end
end
