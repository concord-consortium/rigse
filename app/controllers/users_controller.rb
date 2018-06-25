class UsersController < ApplicationController

  after_filter :store_location, :only => [:index]

  protected

  def not_authorized_error_message
    super({resource_type: 'user', resource_name: @user ? @user.name : nil})
  end

  public

  def new
    #This method is called when a user tries to register as a member
    @user = User.new
  end

  def index
    authorize User
    @users = policy_scope(User).search(params[:search], params[:page], nil).
      includes(:imported_user, :portal_teacher, :portal_student,
              :teacher_cohorts, :student_cohorts, :roles)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    authorize @user
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end
  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    authorize @user
    @roles = Role.all
    @projects = Admin::Project.all_sorted
  end

  # GET /users/1/preferences
  def preferences
    @user = User.find(params[:id])
    authorize @user
    @roles = Role.all
    @projects = Admin::Project.all_sorted
  end

  #
  # GET /users/1/favorites
  #
  def favorites
    @user = User.find(params[:id])
    authorize @user
  end

   # /users/1/switch
  def switch
    @user = User.find(params[:id])
    authorize @user
    if params[:commit] == "Switch"
      if switch_to_user = User.find(params[:user][:id])
        switch_from_user = current_visitor
        original_user_from_session = session[:original_user_id]
        recently_switched_from_users = (session[:recently_switched_from_users] || []).clone
        sign_out self.current_visitor
        sign_in switch_to_user

        # the original user is only set on the session once:
        # the first time an admin switches to another user
        unless original_user_from_session
          session[:original_user_id] = switch_from_user.id
        end
        recently_switched_from_users.insert(0, switch_from_user.id)
        session[:recently_switched_from_users] = recently_switched_from_users.uniq
      end
    end
    redirect_to home_path
  end

  def update
    if params[:commit] == "Cancel"

      redirect_to view_context.class_link_for_user

    else

      @user = User.find(params[:id])
      authorize @user
      respond_to do |format|
        if @user.update_attributes(params[:user])

          # This update method is shared with admins using users/edit and users using users/preferences.
          # Since the values are checkboxes we can't use the absense of them to denote there are no
          # roles or projects in the form since unchecked checkboxes are not part of the post body.
          # We also can't just rely on the current user role as they may be changing their own preferences
          if current_visitor.has_role?("admin", "manager")
            if params[:user][:has_roles_in_form]
              @user.set_role_ids(params[:user][:role_ids] || [])
            end
            if params[:user][:has_projects_in_form]
              all_projects = Admin::Project.all
              @user.set_role_for_projects('admin', all_projects, params[:user][:admin_project_ids] || [])
              @user.set_role_for_projects('researcher', all_projects, params[:user][:researcher_project_ids] || [])
              @user.set_role_for_projects('member', all_projects, params[:user][:member_project_ids] || [])
            end
          elsif current_visitor.is_project_admin?
            if params[:user][:has_projects_in_form]
              @user.set_role_for_projects('researcher', current_visitor.admin_for_projects, params[:user][:researcher_project_ids] || [])
            end
          end

          if @user.portal_teacher && params[:user][:has_cohorts_in_form]
            @user.portal_teacher.set_cohorts_by_id(params[:user][:cohort_ids] || [])
          end

          flash[:notice] = "User: #{@user.name} was successfully updated."
          format.html do
            redirect_to view_context.class_link_for_user
          end
          format.xml  { head :ok }
        else
          # need the roles and projects instance variables for the edit template
          @roles = Role.all
          @projects = Admin::Project.all_sorted
          format.html { render :action => "edit" }
          format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  def account_report
    rep = Reports::Account.new({:verbose => false})
    book = rep.run_report
    send_data(book.to_data_string, :type => book.mime_type, :filename => "accounts-report.#{book.file_extension}" )
  end

  def reset_password
    @user = User.find(params[:id])
    authorize @user
    p = Password.new(:user_id => params[:id])
    p.save(:validate => false) # we don't need the user to have a valid email address...
    session[:return_to] = request.referer
    redirect_to change_password_path(:reset_code => p.reset_code)
  end

  def backdoor
    sign_out :user
    user = User.find_by_login!(params[:username])
    sign_in user
    render :text => "#{params[:username]} logged in"
  end

  #Used for activation of users by a manager/admin
  def confirm
    user = User.find(params[:id])
    authorize user
    if user.state != "active"
      user.confirm!
      user.make_user_a_member
      # assume this type of user just activated someone from somewhere else in the app
      flash[:notice] = "Activation of #{user.name_and_login} complete."
      redirect_to(session[:return_to] || root_path)
    end
  end

  def registration_successful
    if params[:type] == "teacher"
      render :template => 'users/thanks'
    else
      render :template => 'portal/students/signup_success'
    end
  end

  def limited_edit
    @user = User.find(params[:id])
    authorize @user
    @projects = Admin::Project.all_sorted
  end

  def limited_update
    if params[:commit] == "Cancel"
      redirect_to users_path
    else
      @user = User.find(params[:id])
      authorize @user
      respond_to do |format|
        if params[:user][:has_projects_in_form]
          @user.set_role_for_projects('researcher', current_visitor.admin_for_projects, params[:user][:researcher_project_ids] || [])
        end
        if @user.portal_teacher && params[:user][:has_cohorts_in_form]
          @user.portal_teacher.set_cohorts_by_id(params[:user][:cohort_ids] || [])
        end
        flash[:notice] = "User: #{@user.name} was successfully updated."
        format.html do
          redirect_to users_path
        end
        format.xml  { head :ok }
      end
    end
  end
end
