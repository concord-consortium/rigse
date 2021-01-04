class LearnerDetailPolicy < ApplicationPolicy

  def show?
    request_is_peer?
  end
end
