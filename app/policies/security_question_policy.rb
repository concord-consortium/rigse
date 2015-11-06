class SecurityQuestionPolicy < ApplicationPolicy

  def edit?
    student?
  end

  def update?
    student?
  end

end
