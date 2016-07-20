class ConfirmationsController < Devise::ConfirmationsController

  def after_confirmation_path_for(resource_name, resource)
    # resource = user
    # Redirect teacher back to the page where he signed up.
    resource.portal_teacher && resource.sign_up_path || home_path
  end

end
