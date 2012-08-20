class Report::OfferingStatus
  attr_accessor :offering
  attr_accessor :students
  attr_accessor :student_statuses
  attr_accessor :student_status_map

  # this has an offering
  # and it constructs the statuses for all the students 
  def initialize(_offering, options = {})
    self.offering = _offering
    self.student_status_map = {}
    self.student_statuses = []
    learners = offering.learners.includes(:report_learner, :learner_activities)
    
    # sort students by full name
    self.students = offering.clazz.students.includes(:user)
    self.students = self.students.sort{|a,b| a.user.full_name.downcase<=>b.user.full_name.downcase}

    students.each{|student|
      student_status = Report::OfferingStudentStatus.new
      student_status.student = student
      student_status_map[student] = student_status
      student_statuses << student_status
      student_status.learner = learners.find{|learner| learner.student_id == student.id}
    }
  end

  # it might make more sense for this to return an offering_student_status object
  def complete_percent(student)
    student_status_map[student].complete_percent
  end

  def activity_complete_percent(student, activity)
    student_status_map[student].activity_complete_percent(activity)
  end
end

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
