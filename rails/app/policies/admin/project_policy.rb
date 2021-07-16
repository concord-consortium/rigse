class Admin::ProjectPolicy < ApplicationPolicy
  def permitted_attributes
    if user.has_role?('admin')
      [
        :name,
        :public,
        :landing_page_slug,
        :landing_page_content,
        :project_card_image_url,
        :project_card_image_description,
        :links, :cohorts
      ]
    else
      [
        :name,
        :landing_page_content,
        :project_card_image_url,
        :project_card_image_description,
        :links,
        :cohorts
      ]
    end
  end

  class Scope < Scope
    def resolve
      if user.has_role?('admin')
        all
      elsif user.is_project_admin?
        user.admin_for_projects
      elsif user.is_project_researcher?
        user.researcher_for_projects
      else
        none
      end
    end
  end

  def index?
    admin_or_project_admin?
  end

  def new_or_create?
    admin?
  end

  def landing_page?
    # students aren't allowed to visit landing pages
    ! student?
  end

  def update_or_edit?
    user.present? && (user.has_role?('admin') || user.is_project_admin?(record))
  end

  def update?
    update_or_edit?
  end

  def edit?
    update_or_edit?
  end

  def destroy?
    user.present? && user.has_role?('admin')
  end

  def not_anonymous?
    admin_or_project_admin?
  end

  # Visible on the search page, home page, navigation bar, etc.
  def visible?
    record.public || admin? || user && user.is_project_member?(record)
  end

  def assign_to_material?
    admin? || user && user.is_project_admin?(record)
  end

  def api_show?
    teacher? || admin?
  end
end
