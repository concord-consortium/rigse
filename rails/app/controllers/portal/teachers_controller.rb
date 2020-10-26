class Portal::TeachersController < ApplicationController
  include RestrictedPortalController
  # PUNDIT_CHECK_FILTERS
  before_filter :teacher_admin_or_manager, :except=> [:new, :create]
  public

  def teacher_admin_or_manager
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::Teacher
    # authorize @teacher
    # authorize Portal::Teacher, :new_or_create?
    # authorize @teacher, :update_edit_or_destroy?
    if current_visitor.has_role?('admin') ||
       current_visitor.has_role?('manager') ||
       (current_visitor.portal_teacher && current_visitor.portal_teacher.id.to_s == params[:id])
       # this user is authorized
       true
    else
      raise Pundit::NotAuthorizedError
    end
  end

  # GET /portal_teachers/1
  # GET /portal_teachers/1.xml
  def show
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @teacher
    @portal_teacher = Portal::Teacher.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @portal_teacher }
    end
  end

  # GET /portal_teachers/view
  # GET /portal_teachers/new.xml
  def new
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::Teacher
    @portal_teacher = Portal::Teacher.new
    @school_selector = Portal::SchoolSelector.new(params)
    respond_to do |format|
      format.xml  { render :xml => @portal_teacher }
    end
  end

  # POST /portal_teachers
  # POST /portal_teachers.xml
  # TODO: move some of this into the teachers model.
  def create
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::Teacher

    # TODO: Teachers DO NOT HAVE grades
    @portal_grade = nil
    if params[:grade]
      @portal_grade = Portal::Grade.find(params[:grade][:id])
    end

    @user = User.new(user_strong_params(params[:user]))
    @school_selector = Portal::SchoolSelector.new(params)

    if (@user.valid?)
      # TODO: save backing DB objects
      # @school_selector.save
    end
    @portal_teacher = Portal::Teacher.new do |t|
      t.user = @user
      t.schools << @school_selector.school if @school_selector.valid?
      t.grades << @portal_grade if !@portal_grade.nil?
    end
    @resource = @user
    if @user.valid? && @school_selector.valid? && @resource.save! && @portal_teacher.save
      # will redirect:
      return successful_creation(@user)
    end

    # Luckily, ActiveRecord errors allow you to attach errors to arbitrary, non-existant attributes
    # will redirect:
    @user.errors.add(:you, "must select a school") unless @school_selector.valid?


    failed_creation
  end

  # DELETE /portal_teachers/1
  # DELETE /portal_teachers/1.xml
  def destroy
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @teacher
    @portal_teacher = Portal::Teacher.find(params[:id])
    @portal_teacher.destroy

    respond_to do |format|
      format.html { redirect_to(portal_teachers_url) }
      format.xml  { head :ok }
    end
  end

  def successful_creation(user)
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::Teacher
    # authorize @teacher
    # authorize Portal::Teacher, :new_or_create?
    # authorize @teacher, :update_edit_or_destroy?
    # Render the UsersController#thanks page instead of showing a flash message.
    redirect_to thanks_for_sign_up_url(:type=>"teacher",:login=>"#{user.login}")

  end

  def failed_creation(message = 'Sorry, there was an error creating your account')
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::Teacher
    # authorize @teacher
    # authorize Portal::Teacher, :new_or_create?
    # authorize @teacher, :update_edit_or_destroy?
    # FIXME is the sign_out necessary??? The user should not be signed in yet, however
    # previously there was a current_visitor=User.anonymous here.
    sign_out :user
    flash.now[:error] = message
    render :action => :new
  end

  # STRONG_PARAMS_REVIEW: model attr_accessible didn't match model attributes:
  #  attr_accessible: :can_add_teachers_to_cohorts, :confirmation_token, :confirmed_at, :email, :email_subscribed, :external_id, :first_name, :have_consent, :last_name, :login, :of_consenting_age, :password, :password_confirmation, :remember_me, :require_password_reset, :sign_up_path, :state
  #  model attrs:     :asked_age, :can_add_teachers_to_cohorts, :confirmation_sent_at, :confirmation_token, :confirmed_at, :current_sign_in_at, :current_sign_in_ip, :default_user, :deleted_at, :email, :email_subscribed, :encrypted_password, :external_id, :first_name, :have_consent, :last_name, :last_sign_in_at, :last_sign_in_ip, :login, :of_consenting_age, :password_salt, :remember_created_at, :remember_token, :require_password_reset, :require_portal_user_type, :reset_password_token, :sign_in_count, :sign_up_path, :site_admin, :state, :unconfirmed_email, :uuid
  def user_strong_params(params)
    params && params.permit(:asked_age, :can_add_teachers_to_cohorts, :confirmation_sent_at, :confirmation_token, :confirmed_at,
                            :current_sign_in_at, :current_sign_in_ip, :default_user, :deleted_at, :email, :email_subscribed,
                            :encrypted_password, :external_id, :first_name, :have_consent, :last_name, :last_sign_in_at, :last_sign_in_ip,
                            :login, :of_consenting_age, :password_salt, :remember_created_at, :remember_token, :require_password_reset,
                            :require_portal_user_type, :reset_password_token, :sign_in_count, :sign_up_path, :site_admin, :state,
                            :unconfirmed_email, :uuid)
  end
end
