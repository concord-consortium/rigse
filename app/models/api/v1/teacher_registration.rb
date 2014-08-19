class API::V1::TeacherRegistration < API::V1::UserRegistration

  attribute :school_id,  Integer

  attr_reader :teacher

  validate  :school_id_checker
  
  def school_id_checker
    found = Portal::School.find(self.school_id)
    return true if found
    self.errors.add(:school_id, "Unknown school (#{school_id})")
  end

  protected
  def persist_teacher
    user.portal_teacher = @teacher = Portal::Teacher.create(:user => user)
    # We need to send / receive confirmation email before: user.confirm!
    return true
  end

  def persist!
    return super && persist_teacher
  end

end
