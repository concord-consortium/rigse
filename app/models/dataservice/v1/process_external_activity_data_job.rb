class Dataservice::V1::ProcessExternalActivityDataJob < Dataservice::ProcessExternalActivityDataJob

  attr_accessor :portal_start

  def initialize(_learner, _content, _portal_start)
    super(_learner, _content)
    self.portal_start = _portal_start
    self.answers =  JSON.parse(content)['answers'] rescue []
  end

  def lara_start
    # this will be nil if there aren't any dirty answers when lara sent the data
    # and we want to leave it that way
    DateTime.parse(JSON.parse(content)['lara_start']) rescue nil
  end

  def lara_end
    DateTime.parse(JSON.parse(content)['lara_end']) rescue Time.now()
  end

  def perform
    super
    processing_event =
      LearnerProcessingEvent.build_proccesing_event(learner, lara_start, lara_end, portal_start, answers.length)
    processing_event.save
  end
end
