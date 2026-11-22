class SecurityQuestionPolicy < ApplicationPolicy

  # A teacher preview student account has no security questions: nobody can sign in to it directly.
  def edit?
    student? && !user.teacher_preview_student?
  end

  def update?
    student? && !user.teacher_preview_student?
  end

end
