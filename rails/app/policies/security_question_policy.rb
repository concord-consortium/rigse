class SecurityQuestionPolicy < ApplicationPolicy

  # A teacher learner account has no security questions: nobody can sign in to it directly.
  def edit?
    student? && !user.teacher_learner?
  end

  def update?
    student? && !user.teacher_learner?
  end

end
