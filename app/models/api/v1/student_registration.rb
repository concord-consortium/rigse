class API::V1::StudentRegistration < API::V1::UserRegistration

  attribute :over_18,    Boolean
  attribute :class_word, String
  attribute :questions,  Array[String]
  attribute :answers,    Array[String]

  validates :class_word, presence: true
  
  validate  :valid_class_word_checker
  validate  :enough_questions_checker
  validate  :enough_answers_checker

  def make_login
    Portal::Student.generate_user_login(self.first_name || "john", self.last_name || "doe")
  end
  
  def make_email
    Portal::Student.generate_user_email
  end

  def set_defaults
    super
    self.login = make_login
    self.email = make_email
  end

  def valid_class_word_checker
    found = Portal::Clazz.find_by_class_word(self.class_word)
    return true if found
    errors.add(:class_word, "incorrect class word")
    return false
  end

  def num_required_questions
    3
  end

  def enough_questions_checker
    return true if (self.questions.uniq.reject { |i| i.blank? }.size == num_required_questions)
    errors.add(:questions, "You must choose #{num_required_questions} unique questions")
    return false
  end

  def enough_answers_checker
    return true if (self.answers.reject { |i| i.blank? }.size == num_required_questions)
    errors.add(:answers, "You must have #{num_required_questions} non-blank answers")
    return false
  end

end