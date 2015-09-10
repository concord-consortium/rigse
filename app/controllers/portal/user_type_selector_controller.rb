class Portal::UserTypeSelectorController < ApplicationController
  public

  def index
    if current_visitor && !current_visitor.has_portal_user_type?
      @wide_content_layout = true
    else
      redirect_to home_path
    end
  end

end
