class API::V1::TeacherRegistration < API::V1::UserRegistration

  attribute :school_id,  Integer

  attr_reader :teacher

  validate  :school_id_checker
  
  def school_id_checker
    begin
      found = Portal::School.find(self.school_id)
      return true if found
    rescue
    end
    self.errors.add(:school_id, "You must select a valid school")
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
