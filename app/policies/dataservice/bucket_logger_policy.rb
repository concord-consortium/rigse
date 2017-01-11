class Dataservice::BucketLoggerPolicy < ApplicationPolicy

  def show?
    admin?
  end

  def show_by_learner?
    admin?
  end

  def show_by_name?
    admin?
  end

  def show_log_items_by_learner?
    admin?
  end

  def show_log_items_by_name?
    admin?
  end

end
