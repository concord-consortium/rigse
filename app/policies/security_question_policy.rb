class SecurityQuestionPolicy < ApplicationPolicy

  def edit?
    has_security_questions?
  end

  def update?
    has_security_questions?
  end

  private

  def has_security_questions?
    user && !user.portal_student.nil?
  end
end
