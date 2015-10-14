# encoding: UTF-8

include ActionView::Helpers::DateHelper

# |Name|User Name|Last Login|Assignments Started|

class StudentRosterRow
  NO_NAME                = I18n.t "RosterNoName"
  NO_LOGIN               = I18n.t "RosterNoLogin"
  NO_LAST_LOGIN          = I18n.t "RosterNoLastLogin"
  NO_ASSIGNMENTS         = I18n.t "RosterNoAssignments"
  AGO                    = I18n.t "RosterTimeAgo"
  NEVER                  = I18n.t "RosterNeverLoggedIn"

  attr_accessor :student
  attr_accessor :clazz
  attr_accessor :portal_student_clazz
  attr_accessor :login
  attr_accessor :last_login
  attr_accessor :assignments_started

  def initialize(_student, _clazz)
    self.student = _student
    self.clazz = _clazz
    self.portal_student_clazz = self.clazz.student_clazzes.find_by_student_id(self.student.id)
  end

  def name
    begin
      name = "#{self.student.user.last_name }, #{self.student.user.first_name}"
      name.truncate(33)
    rescue
      NO_NAME
    end
  end

  def login
    begin
      self.student.user.login.truncate(20)
    rescue
      NO_LOGIN
    end
  end

  def last_login
    begin
      date = self.student.user.last_sign_in_at
      return NEVER unless date
      wordtime = "#{time_ago_in_words(date)} #{AGO}"
      datetime = date.strftime "%Y-%m-%d %l:%M %Z"
      wordtime
    rescue
      NO_LAST_LOGIN
    end
  end

  def assignments_started
    begin
      self.student.learners.select { |l| l.offering.clazz_id == self.clazz.id }.length
    rescue
      NO_ASSIGNMENTS
    end
  end

  def confirm_delete_message
    I18n.t "RosterConfirmDelete", name: self.name, clazz: self.clazz.name
  end

end
