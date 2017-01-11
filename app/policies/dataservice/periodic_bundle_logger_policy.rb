class Dataservice::PeriodicBundleLoggerPolicy < ApplicationPolicy

  def show?
    admin?
  end

end
