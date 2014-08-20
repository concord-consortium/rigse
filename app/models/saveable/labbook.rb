class Saveable::Labbook
  attr_accessor :embeddable
  attr_accessor :learner
  cattr_accessor :request

  # This "saveable" isn't really. Its faked.
  # include Saveable::Saveable
  def answered?
    true
  end

  def answer
    ::Labbook.url(learner, Saveable::Labbook.request, embeddable)
  end

  def answered_correctly?
    false
  end

  def learner_id
    learner.id
  end

  def initialize(_embeddable, _learner)
    self.embeddable = _embeddable
    self.learner = _learner
  end

  def self.find_all_by_offering_id(id)
    offering = Portal::Offering.find(id)
    return saveables_for_offering(offering, offering.learners)
  end

  def self.find_all_by_learner_id(id)
    learner = Portal::Learner.find(id)
    return saveables_for_offering(learner.offering, [learner])
  end

  def self.saveables_for_offering(offering, learners)
    saveables = []
    runnable = offering.runnable
    ((runnable.embedded_models rescue []) + (runnable.sensors rescue []) + (runnable.drawing_tools rescue [])).each do |model|
      learners.each do |learner|
        saveables << Saveable::Labbook.new(model, learner)
      end
    end
    return saveables
  end
end
