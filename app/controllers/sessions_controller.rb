class SessionsController < Devise::SessionsController
  def destroy
    cookies.delete :current_user_single_sign_on_id
    redirect_path = request.referer
    sign_out current_user
    redirect_to redirect_path
  end

end

