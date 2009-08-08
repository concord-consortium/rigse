class Portal::TeachersController < ApplicationController
  # GET /portal_teachers
  # GET /portal_teachers.xml
  def index
    @teachers = Portal::Teacher.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @teachers }
    end
  end

  # GET /portal_teachers/1
  # GET /portal_teachers/1.xml
  def show
    @teacher = Portal::Teacher.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @teacher }
    end
  end

  # GET /portal_teachers/new
  # GET /portal_teachers/new.xml
  def new
    @teacher = Portal::Teacher.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @teacher }
    end
  end

  # GET /portal_teachers/1/edit
  def edit
    @teacher = Portal::Teacher.find(params[:id])
    @user = @teacher.user
  end

  # POST /portal_teachers
  # POST /portal_teachers.xml
  def create
    @user = User.new(params[:user])
    if @user && @user.valid?
      @user.register!
      @user.save
    end
    
    @teacher = Portal::Teacher.new(params[:teacher])
    @teacher.user = @user
    
    if @user.errors.empty? && @teacher.save
      # will redirect:
      @user.save 
      
      successful_creation(@user)    
    else 
      # will redirect:
      failed_creation
    end
    
  end

  # PUT /portal_teachers/1
  # PUT /portal_teachers/1.xml
  def update
    @teacher = Portal::Teacher.find(params[:id])

    respond_to do |format|
      if @teacher.update_attributes(params[:teacher])
        flash[:notice] = 'Portal::Teacher was successfully updated.'
        format.html { redirect_to(@teacher) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @teacher.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /portal_teachers/1
  # DELETE /portal_teachers/1.xml
  def destroy
    @teacher = Portal::Teacher.find(params[:id])
    @teacher.destroy

    respond_to do |format|
      format.html { redirect_to(portal_teachers_url) }
      format.xml  { head :ok }
    end
  end
  
  def successful_creation(user)
    flash[:notice] = "Thanks for signing up!"
    flash[:notice] << " We're sending you an email with your activation code."
    redirect_back_or_default(root_path)
  end
  
  def failed_creation(message = 'Sorry, there was an error creating your account')
    # force the current_user to anonymous, because we have not successfully created an account yet.
    # edge case, which we might need a more integrated solution for??
    self.current_user = User.anonymous
    flash[:error] = message
    render :action => :new
  end
  
  
end
