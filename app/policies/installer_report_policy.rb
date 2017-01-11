class InstallerReportPolicy < ApplicationPolicy

  def index?
    admin?
  end

end
