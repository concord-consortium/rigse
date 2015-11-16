class HomePolicy < Struct.new(:user, :home)
  attr_reader :user, :home

  def initialize(context, home)
    @user = context.user
    @home = home
  end

  def admin?
    user && (user.is_project_admin? || user.is_project_researcher? || user.has_role?('manager','admin','researcher'))
  end

  def recent_activity?
    user && user.portal_teacher
  end

end
