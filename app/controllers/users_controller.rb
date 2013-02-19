class UsersController < ApplicationController
  # skip_before_filter :verify_authenticity_token, :only => :create
  #access_rule 'admin', :only => [:index, :show, :new, :edit, :update, :destroy]
  #access_rule 'admin || manager || researcher', :only => [:index, :account_report]
  include RestrictedController
  before_filter :changeable_filter,
    :only => [
      :show,
      :edit,
      :update,
      :reset_password
    ]
  before_filter :manager, :only => [:destroy]
  before_filter :manager_or_researcher,
    :only => [
      :index,
      :account_report
    ]
  after_filter :store_location, :only => [:index]

  def changeable_filter
    @user = User.find(params[:id])
    redirect_home unless @user.changeable?(current_visitor)
  end

  def index
    if params[:mine_only]
      @users = User.search(params[:search], params[:page], self.current_visitor)
    else
      @users = User.search(params[:search], params[:page], nil)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def new
    @user = User.new
  end

  def create
    logout_keeping_session!
    create_new_user(params[:user])
    # redirect_to(root_path) # (no need to redirect here, the above controller did it.)
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    @roles = Role.all
    unless @user.changeable?(current_visitor)
      flash[:warning]  = "You need to be logged in first."
      redirect_to login_url
    end
  end

  # GET /users/1/edit
  def preferences
    @user = User.find(params[:id])
    @roles = Role.all
    unless @user.changeable?(current_visitor)
      flash[:warning]  = "You need to be logged in first."
      redirect_to login_url
    end
  end

  # /users/1/switch
  def switch
    # @original_user is setup in app/controllers/application_controller.rb
    unless @original_user.has_role?('admin', 'manager')
      redirect_to home_path
    else
      if request.get?
        @user = User.find(params[:id])
        all_users = User.active.all
        all_users.delete(current_visitor)
        all_users.delete(User.anonymous)
        all_users.delete_if { |user| user.has_role?('admin') } unless @original_user.has_role?('admin')

        recent_users = []
        (session[:recently_switched_from_users]  || []).each do |user_id|
          recent_user = all_users.find { |u| u.id == user_id }
          recent_users << all_users.delete(recent_user) if recent_user
        end

        users = all_users.group_by do |u|
          case
          when u.default_user   then :default_users
          when u.portal_student then :student
          when u.portal_teacher then :teacher
          else :regular
          end
        end

        # to avoid nil values, initialize everything to an empty array if it's non-existent
        # users[:student] ||= []
        # users[:regular] ||= []
        # users[:default_users] ||= []
        # users[:student].sort! { |a, b| a.first_name.downcase <=> b.first_name.downcase }
        # users[:regular].sort! { |a, b| a.first_name.downcase <=> b.first_name.downcase }
        [:student, :regular, :default_users, :student, :teacher].each do |ar|
          users[ar] ||= []
          users[ar].sort! { |a, b| a.last_name.downcase <=> b.last_name.downcase }
        end
        @user_list = [ 
          { :name => 'recent' ,   :users => recent_users     } ,
          { :name => 'guest',     :users => [User.anonymous] } ,
          { :name => 'regular',   :users => users[:regular]  } ,
          { :name => 'students',  :users => users[:student]  } ,
          { :name => 'teachers',  :users => users[:teacher]  } 
        ]
        if users[:default_users] && users[:default_users].size > 0
          @user_list.insert(2, { :name => 'default', :users => users[:default_users] })
        end
      elsif request.put?
        if params[:commit] == "Switch"
          if switch_to_user = User.find(params[:user][:id])
            unless session[:original_user_id]  # session[:original_user_auth_token]
              session[:original_user_id] = current_visitor.id
            end
            recently_switched_from_users = (session[:recently_switched_from_users] || []).clone
            recently_switched_from_users.insert(0, current_visitor.id)
            self.current_visitor=(switch_to_user)
            session[:recently_switched_from_users] = recently_switched_from_users.uniq
          end
        elsif params[:commit] =~ /#{@original_user.name}/
          self.current_visitor=(@original_user)
        end
        redirect_to home_path
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    if params[:commit] == "Cancel"
      # FIXME: ugly hack
      # if the Cancel request came from a form generated by
      # the preferences action then redirect to /home
      if request.env["HTTP_REFERER"] =~ /preferences/
        redirect_to :home
      else
        redirect_to users_path
      end
    else
      @user = User.find(params[:id])
      respond_to do |format|
        if @user.update_attributes(params[:user])
          @user.set_role_ids(params[:user][:role_ids]) if params[:user][:role_ids]

          # set the cohort tags if we have a teacher
          if @user.portal_teacher && params[:update_cohorts]
            cohorts = params[:cohorts] ? params[:cohorts] : []
            @user.portal_teacher.cohort_list = cohorts
            @user.portal_teacher.save
          end

          flash[:notice] = "User: #{@user.name} was successfully updated."
          format.html do
            if request.env["HTTP_REFERER"] =~ /preferences/
              redirect_to :home
            else
              redirect_to users_path
            end
          end
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
    end
  end


  def activate
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      user.make_user_a_member
      if current_visitor && current_visitor.has_role?('admin', 'manager')
        # assume this type of user just activated someone from somewhere else in the app
        flash[:notice] = "Activation of #{user.name_and_login} complete."
        redirect_to(session[:return_to] || root_path)
      else
        logout_keeping_session!
        flash[:notice] = "Signup complete! Please sign in to continue."
        redirect_to login_path
      end
    when params[:activation_code].blank?
      logout_keeping_session!
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default(root_path)
    else
      logout_keeping_session!
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default(root_path)
    end
  end

  def interface
    # Select the probeware vendor and interface to use when generating jnlps and otml
    # files. This redult is saved in a session variable and if the user is logged-in
    # the selection is also saved into their user record.
    # The result is expressed not only in the jnlp and otml files which are
    # downloaded to the users computer but the vendor_interface id (vid) which is
    # also included in the contruction of the url
    @user = User.find(params[:id])
    if request.xhr?
      render :partial => 'interface', :locals => { :vendor_interface => @user.vendor_interface }
    else
      if !@user.changeable?(current_visitor)
        flash[:warning]  = "You need to be logged in first."
        redirect_to login_url
      else

        if params[:commit] == "Cancel"
          redirect_back_or_default(home_url)
        else
          if request.put?
            respond_to do |format|
              if @user.update_attributes(params[:user])
                format.html {  redirect_back_or_default(home_url) }
                format.xml  { head :ok }
              else
                format.html { render :action => "interface" }
                format.xml  { render :xml => @user.errors.to_xml }
              end
            end
          else
            # @vendor_interface = current_visitor.vendor_interface
            # @vendor_interfaces = Probe::VendorInterface.all.map { |v| [v.name, v.id] }
            # session[:back_to] = request.env["HTTP_REFERER"]
            # render :action => "interface"
          end
        end
      end
    end
  end

  def vendor_interface
    v_id = params[:vendor_interface]
    if v_id
      @vendor_interface = Probe::VendorInterface.find(v_id)
      render :partial=>'vendor_interface', :layout=>false
    else
      render(:nothing => true)
    end
  end

  def account_report
    sio = StringIO.new
    rep = Reports::Account.new({:verbose => false})
    rep.run_report(sio)
    send_data(sio.string, :type => "application/vnd.ms.excel", :filename => "accounts-report.xls" )
  end

  def reset_password
    p = Password.new(:user_id => @user.id)
    p.save(:validate => false) # we don't need the user to have a valid email address...
    session[:return_to] = request.referer
    redirect_to change_password_path(:reset_code => p.reset_code)
  end

  protected

  def create_new_user(attributes)
    @user = User.new(attributes)
    if @user && @user.valid?
      @user.register!
    end
    if @user.errors.empty?
      self.current_visitor = User.anonymous
      render :action => :thanks
    else
      # will redirect:
      failed_creation
    end
  end



  def failed_creation(message = 'Sorry, there was an error creating your account')
    # force the current_visitor to anonymous, because we have not successfully created an account yet.
    # edge case, which we might need a more integrated solution for??
    self.current_visitor = User.anonymous
    flash.now[:error] = message
    render :action => :new
  end
end
