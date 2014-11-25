# this is only used when new learner data comes in and the report_learner needs to be
# updated
class Report::UtilLearner
  attr_accessor :offering, :saveables, :embeddables

  def initialize(learner)
    @offering = learner.offering

    assignable = @offering.runnable
    if assignable.is_a?(ExternalActivity) && assignable.template
      assignable = assignable.template
    end

    @saveables           = []
    @reportables         = assignable.reportable_elements
    @embeddables         = @reportables.map       { |r| r[:embeddable] }

    # the types are split out here instead of using ResponseTypes so we
    # can fetch all the pieces we need in fewer DB reqests
    # the pieces we need are: the answer, parts for answered? and answered_correctly?,
    @saveables += Saveable::OpenResponse.find_all_by_learner_id(learner.id)
    @saveables += Saveable::MultipleChoice.find_all_by_learner_id(learner.id)
    @saveables += Saveable::ImageQuestion.find_all_by_learner_id(learner.id)
    @saveables += Saveable::ExternalLink.find_all_by_learner_id(learner.id)

    # ResponseTypes.saveable_types.each do |type|
    #   all = type.find_all_by_learner_id(learner.id)
    #   @saveables += all
    # end

    # If an investigation has changed, and saveable elements have been removed (eek!)
    # we are checking which saveables have a cooresponding embeddable
    current =  @saveables.select { |s| @embeddables.include? s.embeddable}
    old = @saveables - current
    if old.size > 0
      warning = "WARNING: missing #{old.size} removed reportables in report for #{assignable.name}"
      puts warning
      Rails.logger.info(warning)
      @saveables = current
    end

  end

  def complete_number(activity = nil)
    if activity
      # filter saveables by only the embeddables with the same activity
      embeddables = @reportables.select { |r| r[:activity] && r[:activity].id == activity.id}.map { |r| r[:embeddable]}
      saveables.count { |s| s.submitted? && embeddables.include?(s.embeddable) }
    else
      saveables.count { |s| s.submitted? }
    end
  end

  def complete_percent(activity = nil)
    completed = Float(complete_number(activity))
    if activity
      total = Float(@reportables.count { |r| r[:activity] && r[:activity].id == activity.id})
    else
      total = Float(embeddables.size)
    end
    return total < 0.5 ? 0.0 : (completed/total) * 100.0
  end
end
