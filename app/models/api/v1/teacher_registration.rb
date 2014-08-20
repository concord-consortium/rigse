class API::V1::TeacherRegistration < API::V1::UserRegistration

  attribute :school_id, Integer

  attr_reader :teacher

  validate :school_id_checker

  def allow_teacher_school_creation
    Admin::Project.default_project.allow_adhoc_schools
  end

  def school_id_checker
    begin
      return true if school
    rescue
    end
    self.errors.add(:school_id, "You must select a valid school")
  end

  def school
    Portal::School.find(self.school_id)
  end

  protected
  def persist_teacher
    user.portal_teacher = @teacher = Portal::Teacher.new(:user => user)
    @teacher.schools << school
    @teacher.save!
    # We need to send / receive confirmation email before: user.confirm!
    return true
  end

  def persist!
    return super && persist_teacher
  end

end
