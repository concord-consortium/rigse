class Report::Learner::LearnerPolicy < ApplicationPolicy

  def index?
    manager_or_researcher?
  end

  def logs_query?
    manager_or_researcher?
  end

  def update_learners?
    manager_or_researcher?
  end
end
