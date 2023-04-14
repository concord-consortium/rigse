class Report::OfferingStudentStatus
  attr_accessor :learner
  attr_accessor :student
  attr_accessor :offering

  def self.get_for_offering_and_student(offering, student)
    learners = offering.learners.includes(:report_learner)
    student_status = Report::OfferingStudentStatus.new
    student_status.student = student
    student_status.learner = learners.find{ |learner| learner.student_id == student.id }
    student_status.offering = offering
    student_status
  end

  def display_report_link?
    (offering && offering.student_report_enabled? && offering_reportable?)
  end

  def offering_reportable?
    (offering && offering.individual_student_reportable?)
  end

  # this is redundant with the Report::Learner object, but that object doesn't handle
  # students that don't have learners for the offering
  def complete_percent
    if learner
      # check if this is a reportable thing, if not then base the percent on the existance of the learner
      if offering_reportable?
        learner.report_learner.complete_percent || 0
      else
        # Offering is not reportable, but it has been started. Return 100%.
        100
      end
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
    Report::Learner.build_last_run_string(last_run, opts)
  end

end
