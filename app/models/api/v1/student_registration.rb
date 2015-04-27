class API::V1::StudentRegistration < API::V1::UserRegistration

  attribute :class_word, String
  attribute :questions,  Array[String]
  attribute :answers,    Array[String]

  attr_reader :student

  validate  :valid_class_word_checker
  validate  :questions_checker
  validate  :answers_checker

  def make_login
    Portal::Student.generate_user_login(self.first_name || "john", self.last_name || "doe")
  end

  def make_email
    Portal::Student.generate_user_email
  end

  # Called before validation, see UserRegistration class.
  def set_defaults
    super
    self.login ||= make_login
    self.email ||= make_email
  end

  def valid_class_word_checker
    found = Portal::Clazz.find_by_class_word(self.class_word)
    return true if found
    errors.add(:class_word, "Unknown class word")
    return false
  end

  def num_required_questions
    0
  end

  def add_questions_error(indx)
    errors.add(:"questions[#{indx}]", "You must select #{num_required_questions} different questions")
  end

  def questions_checker
    seen_questions = []
    still_valid = true
    for i in 0...num_required_questions do
      q = questions[i]
      if q.blank? or seen_questions.include? q
        add_questions_error(i)
        still_valid = false
      end
      seen_questions << q
    end
    return still_valid
  end

  def add_answer_error(indx)
    errors.add(:"answers[#{indx}]", "You must have #{num_required_questions} non-blank answers")
  end

  def answers_checker
    still_valid = true
    for i in 0...num_required_questions do
      a = answers[i]
      if a.blank?
        add_answer_error(i)
        still_valid = false
      end
    end
    return still_valid
  end

  def make_security_questions
    sec_questions = []
    for i in 0...([num_required_questions, questions.length].max)
      sec_questions << SecurityQuestion.new(:question => questions[i], :answer => answers[i], :user_id => user.id)
    end
    return sec_questions
  end

  protected

  def should_skip_email_notification
    true
  end

  def should_skip_login_validation
    # Login is auto-generated and possible conflicts will be handled during saving
    # (see #persist! method).
    true
  end

  def add_security_questions
    user.update_security_questions!(make_security_questions)
  end

  def persist_student
    user.portal_student = @student = Portal::Student.create(:user => user)
    user.portal_student.process_class_word(self.class_word)
    add_security_questions
    user.confirm!
    return true
  end

  def persist!
    # Due to the race condition it may happen that login isn't unique.
    # See: https://www.pivotaltracker.com/story/show/79274428
    # There are two moments when it can be detected:
    # - ActiveRecord validation
    # - database update
    # In both cases generate login and try to save user again.
    user_save_attempts = 0
    max_attempts = 25
    user_saved = false
    while !user_saved && user_save_attempts <= max_attempts
      begin
        user_save_attempts += 1
        user_saved = super
      rescue ActiveRecord::RecordNotUnique => e
        self.login = make_login
      rescue ActiveRecord::RecordInvalid => e
        # Make sure that the problem is about 'login' attribute only.
        errors = e.record.errors
        if errors.count == 1 && errors.has_key?(:login)
          self.login = make_login
        else
          raise e
        end
      end
    end
    # Last try without exception handling - make sure that exception is eventually raised
    # if login generation doesn't help.
    user_saved = super if !user_saved
    return user_saved && persist_student
  end

end
