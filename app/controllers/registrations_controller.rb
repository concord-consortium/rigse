class RegistrationsController < Devise::RegistrationsController
  def new
    authorize Registration
    # Building the resource with information that MAY BE available from omniauth!
    build_resource(:first_name => session[:omniauth] && session[:omniauth]['user_info'] && session[:omniauth]['user_info']['first_name'],
       :last_name => session[:omniauth] && session[:omniauth]['user_info'] && session[:omniauth]['user_info']['last_name'],
       :email => session[:omniauth_email] )
    render :new
  end

  def create
    authorize Registration
    build_resource

    # normal processing
    super
    session[:omniauth] = nil unless @user.new_record?
  end

  def build_resource(*args)
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Registration
    # authorize @registration
    # authorize Registration, :new_or_create?
    # authorize @registration, :update_edit_or_destroy?
    super

    if session[:omniauth]
      @user.apply_omniauth(session[:omniauth])
      @user.valid?
    end
  end

  def after_update_path_for(scope)
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Registration
    # authorize @registration
    # authorize Registration, :new_or_create?
    # authorize @registration, :update_edit_or_destroy?
    session[:referrer] ? session[:referrer] : root_path
  end
end
