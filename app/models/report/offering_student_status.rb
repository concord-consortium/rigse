class Report::OfferingStudentStatus
  attr_accessor :learner
  attr_accessor :student

  # this is redundant with the Report::Learner object, but that object doesn't handle
  # students that don't have learners for the offering
  def complete_percent
    if learner
      if learner.report_learner.nil?
        learner.report_learner = Report::Learner.for_learner(learner)
      end

      # this will need to handle the case of external activities
      learner.report_learner.complete_percent
    else
      0
    end
  end

  # the runnable is passed because in somecases we want the progress for a sub part of the
  # this learners runnable
  def activity_complete_percent(activity)
    if learner
      # this is not efficient it has to do queries for each activity
      learner_activity = learner.learner_activities.find{|la| la.activity_id == activity.id}

      # Since there is a learner for this it actually has been started so perhaps
      # we shouldn't return 0 here
      learner_activity ? learner_activity.complete_percent : 0
    else
      0
    end
  end

  def last_run
    if learner && learner.report_learner
      learner.report_learner.last_run
    end
  end

end
