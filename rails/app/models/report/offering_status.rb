class Report::OfferingStatus
  attr_accessor :offering
  attr_accessor :students
  attr_accessor :student_statuses
  attr_accessor :student_status_map
  attr_accessor :requester

  # this has an offering
  # and it constructs the statuses for all the students 
  def initialize(_offering, _requester=nil)
    self.offering = _offering
    self.requester = _requester
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
      student_status.offering = offering
    }
  end

  def student_status_for(student)
    student_status_map[student]
  end
  
  # it might make more sense for this to return an offering_student_status object
  def complete_percent(student)
    student_status_map[student].complete_percent
  end

  def activity_complete_percent(student, activity)
    student_status_map[student].activity_complete_percent(activity)
  end

  def collapsed
    return @collapsed if @collapsed
    return false unless requester
    teacher_full_status = offering.teacher_full_status.find_by_teacher_id(requester.portal_teacher.id)
    @collapsed = teacher_full_status ? teacher_full_status.offering_collapsed : true
  end

  def activities_display_style
    collapsed ? "display:none" : ""
  end

  def offering_display_style
    collapsed ? "" : "display:none"
  end

  def runnable
    return @runnable if @runnable
    runnable = offering.runnable

    if runnable.is_a?(::ExternalActivity) && runnable.template
      @runnable = runnable.template
    else
      @runnable = runnable
    end
    @runnable
  end

  def student_activities
    if runnable.is_a? ::Investigation
      runnable.activities.student_only
    elsif runnable.is_a? ::Activity
      [runnable]
    else
      []
    end
  end

  def show_score?
    if runnable.respond_to? :show_score
      runnable.show_score
    else
      false
    end
  end

  def number_of_scorables
    return @number_of_scorables if @number_of_scorables

    @number_of_scorables = runnable.reportable_elements.count{ |element|
      embeddable = element[:embeddable]
      embeddable.respond_to?(:correctable?) && embeddable.has_correct_answer?
    }
  end
end