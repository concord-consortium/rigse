class API::V1::TeacherRegistration < API::V1::UserRegistration

  attribute :school_id, Integer

  attr_reader :teacher

  validate :school_id_checker

  def school_id_checker
    return true if Portal::School.exists?(self.school_id)
    self.errors.add(:school_id, "You must select a valid school")
    return false
  end

  protected
  def persist_teacher
    user.portal_teacher = @teacher = Portal::Teacher.new(:user => user)
    @teacher.schools << Portal::School.find(self.school_id)
    @teacher.save!
    # We need to send / receive confirmation email before: user.confirm!
    return true
  end

  def persist!
    return super && persist_teacher
  end

end
