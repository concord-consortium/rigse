class Portal::UserTypeSelectorController < ApplicationController
  public

  def index
    authorize Portal::UserTypeSelector
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (did not find instance)
    # @user_type_selectors = policy_scope(Portal::UserTypeSelector)
    if current_visitor && !current_visitor.has_portal_user_type?
      @wide_content_layout = true
    else
      redirect_to home_path
    end
  end

end
