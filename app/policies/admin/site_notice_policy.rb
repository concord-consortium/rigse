class Admin::SiteNoticePolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      all.order('updated_at desc')
    end
  end

  def index?
    admin_or_manager?
  end

  def new_or_create?
    admin_or_manager?
  end

  def update_edit_or_destroy?
    admin_or_manager?
  end

end
