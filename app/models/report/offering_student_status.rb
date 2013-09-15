class Report::OfferingStudentStatus
  attr_accessor :learner
  attr_accessor :student
  attr_accessor :offering

  # loosely based on offering_status.rb#student_activities
  def sub_sections
    runnable = offering.runnable

    if runnable.is_a?(::ExternalActivity) && runnable.template
      runnable = runnable.template
    end

    if runnable.is_a? ::Investigation
      runnable.activities.student_only
    else
      [runnable]
    end
  end

  def display_report_link?
    (offering && offering.student_report_enabled? && offering_reportable?)
  end
  
  def offering_reportable?
    (offering && offering.individual_reportable?)
  end

  # this is redundant with the Report::Learner object, but that object doesn't handle
  # students that don't have learners for the offering
  def complete_percent
    if learner
      # check if this is a reportable thing, if not then base the percent on the existance of the learner
      if offering_reportable?
        learner.report_learner.complete_percent || 0 
      else
        # return 99.99 because all we can tell is whether it is in progress
        # if we return 100 then the progress bar will indicate it is compelete
        # 99.99 is enough to fill up the progress bar but keep the in_progress color
        99.99
      end
    else
      0
    end
  end

  def number_correct
    if learner && offering_reportable?
      num_correct = learner.report_learner.num_correct || 0
    else
      nil
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
    if learner
      return learner.report_learner.last_run
    end
    return nil
  end

  def never_run
    return last_run ? false : true
  end

  def last_run_string(opts={})
    not_run_str = "not yet started" || opts[:not_run]
    prefix      = "Last run"        || opts[:prefix]
    format      = "%b %d, %Y"       || opts[:format]

    return not_run_str if never_run 
    return "#{prefix} #{last_run.strftime(format)}"
  end

end
