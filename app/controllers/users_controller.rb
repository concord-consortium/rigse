class UsersController < ApplicationController
  # skip_before_filter :verify_authenticity_token, :only => :create
  
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
    @roles = Role.find(:all)
  end
  
  # PUT /users/1
  # PUT /users/1.xml
  def update
    unless params[:commit] == "Cancel"
      @user = User.find(params[:id])
      respond_to do |format|
        if @user.update_attributes(params[:user])
          flash[:notice] = "User: #{@user.name} was successfully updated."
          format.html { redirect_to(root_path) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
    end
  end
  
  
  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to login_path
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default(root_path)
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default(root_path)
    end
  end
  
  protected
  
  def create_new_user(attributes)
    @user = User.new(attributes)
    if @user && @user.valid?
      @user.register!
    end
    if @user.errors.empty?
      # will redirect:
      successful_creation(@user)
    else
      # will redirect:
      failed_creation
    end
  end
  
  def successful_creation(user)
    flash[:notice] = "Thanks for signing up!"
    flash[:notice] << " We're sending you an email with your activation code."
    redirect_back_or_default(root_path)
  end
  
  def failed_creation(message = 'Sorry, there was an error creating your account')
    flash[:error] = message
    render :action => :new
  end
end
