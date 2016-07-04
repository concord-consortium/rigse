class API::V1::TeacherRegistration < API::V1::UserRegistration

  attribute :school_id, Integer

  attr_reader :teacher

  validate :school_id_checker

  def school_id_checker
    return true if Portal::School.exists?(self.school_id)
    self.errors.add(:school_id, "You must select a valid school")
    return false
  end

  def self.valid_except_from_school_id(params)
    registration = self.new(params)
    !registration.valid? && registration.errors.count == 1 && registration.errors.include?(:school_id)
  end

  protected

  def persist_teacher
    user.portal_teacher = @teacher = Portal::Teacher.new(:user => user)
    @teacher.schools << Portal::School.find(self.school_id)
    @teacher.save!

    # add is_author to teachers if portal setting is true
    settings = Admin::Settings.default_settings
    if settings && settings.auto_set_teachers_as_authors
      user.add_role("author")
    end

    # We need to send / receive confirmation email before: user.confirm!
    return true
  end

  def persist!
    return super && persist_teacher
  end

end
