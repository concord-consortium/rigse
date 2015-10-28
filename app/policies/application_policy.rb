class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
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
    record.changeable?(user)
  end

end


