class ApplicationPolicy
  attr_reader :user, :record, :request

  def initialize(context, record)
    @user = context.user
    @request = context.request
    @record = record
  end

  def index?
    true
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    new_or_create?
  end

  def new?
    new_or_create?
  end

  def update?
    update_edit_or_destroy?
  end

  def edit?
    update_edit_or_destroy?
  end

  def destroy?
    update_edit_or_destroy?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  def new_or_create?
    not_anonymous?
  end

  def update_edit_or_destroy?
    changeable?
  end

  def not_anonymous?
    user && !user.anonymous?
  end

  def changeable?
    user && record.respond_to?(:changeable?) ? record.changeable?(user) : true
  end

  def project_admin?
    user && user.is_project_admin?
  end

  # from old restricted_controller

  def manager?
    has_roles?('manager','admin','district_admin')
  end

  def admin_or_manager?
    has_roles?('admin', 'manager')
  end

  def manager_or_researcher?
    user && (user.is_project_admin? || has_roles?('manager','admin','researcher'))
  end

  def admin?
    has_roles?('admin')
  end

  def admin_or_project_admin?
    user && (user.is_project_admin? || has_roles?('admin'))
  end

  def admin_or_config?
    user && (user.has_role?('admin') || request.format == :config)
  end

  def has_roles?(*roles)
    user && user.has_role?(*roles)
  end

end


