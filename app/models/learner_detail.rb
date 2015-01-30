# encoding: UTF-8

include ActionView::Helpers::DateHelper
class LearnerDetail
  attr_accessor :learner
  attr_accessor :student_name
  attr_accessor :student_login
  attr_accessor :class_name
  attr_accessor :teacher_name
  attr_accessor :teacher_email
  attr_accessor :activity_name
  attr_accessor :learner_id
  attr_accessor :last_sign_in
  attr_accessor :ip
  attr_accessor :last_run
  attr_accessor :last_report
  attr_accessor :updated_at
  attr_accessor :completed
  attr_accessor :num_submissions
  attr_accessor :activity_url
  attr_accessor :token
  attr_accessor :token_expires
  attr_accessor :valid_token

  def initialize(_learner)
    self.learner         = _learner
    self.student_name    = lookup "student.user.name"
    self.student_login   = lookup "student.user.login"
    self.teacher_name    = lookup "offering.clazz.teacher.name"
    self.teacher_email   = lookup "offering.clazz.teacher.email"
    self.activity_name   = lookup "offering.runnable.name"
    self.ip              = lookup "student.user.last_sign_in_ip"
    self.last_sign_in    = lookup "student.user.last_sign_in_at"
    self.completed       = lookup "report_learner.complete_percent"
    self.num_submissions = lookup "report_learner.num_submitted"
    self.last_run        = lookup "report_learner.last_run"
    self.updated_at      = lookup "report_learner.last_run"
    self.last_report     = lookup "report_learner.last_report"
    self.activity_url    = lookup "offering.runnable.url"
    self.valid_token     = "✖"
    if token = _fetch_token
      self.token_expires = time_ago_in_words(token.access_token_expires_at) if token.access_token_expires_at
      self.token         = token.access_token
      self.valid_token   = "✔" if (token.access_token_expires_at && token.access_token_expires_at > Time.now)
    end
    self.updated_at = time_ago_in_words(self.updated_at) if self.updated_at
    self.last_run = time_ago_in_words(self.last_run) if self.last_run
    self.last_sign_in = time_ago_in_words(self.last_sign_in) if self.last_sign_in
  end

  def lookup(path)
    path_parts = path.split(".")
    obj = self.learner
    part = path_parts.first
    begin
      for part in path_parts
        obj = (obj.send(part.to_sym))
      end
    rescue
      return nil
    end
    return obj
  end

  def default_value
    "???"
  end

  def feilds
    %w[ teacher_name teacher_email
      student_name student_login ip last_sign_in
      valid_token token_expires token
      activity_name activity_url completed
      num_submissions last_run updated_at ]
  end

  def values
    self.feilds.map do |field| 
      { name: field, value: self.send(field.to_sym)}
    end
  end
  
  def to_hash
    hash = {}
    values.each { |v| hash[v[:name]] = v[:value] }
    hash
  end

  def to_json
    to_hash.to_json
  end

  def inspect
    fs = "%s student:%s, teacher:%s, sign in: %s\n %s\n"
    printf fs, self.valid_token, self.student_login, self.teacher_email, self.last_sign_in, self.activity_name
  end

  def to_s
    fs = "%s student:%s, teacher:%s"
    sprintf fs, self.valid_token, self.student_login, self.teacher_email
  end

  def display
    out = ""
    values.each do |v|
      out << sprintf("%20.20s: %s\n", v[:name], v[:value])
    end
    return out
  end

  protected
  def _fetch_token
    token = nil
    begin
      token = learner.user.access_grants.order("access_token_expires_at desc").last
    rescue
    end
    return token
  end
end

