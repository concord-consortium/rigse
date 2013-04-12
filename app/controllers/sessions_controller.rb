class SessionsController < Devise::SessionsController
  def destroy
    cookies.delete :current_user_single_sign_on_id, :domain => '.rites.concord.zeuslearning.com'
    if request.referer
      redirect_path = request.referer
    else
      redirect_path = root_path
    end
    sign_out current_user
    redirect_to redirect_path
  end

end

