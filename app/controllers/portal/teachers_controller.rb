class Portal::TeachersController < ApplicationController
  # GET /portal_teachers
  # GET /portal_teachers.xml
  def index
    @portal_teachers = Portal::Teacher.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @portal_teachers }
    end
  end

  # GET /portal_teachers/1
  # GET /portal_teachers/1.xml
  def show
    @portal_teacher = Portal::Teacher.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @portal_teacher }
    end
  end

  # GET /portal_teachers/new
  # GET /portal_teachers/new.xml
  def new
    @portal_teacher = Portal::Teacher.new
    @portal_districts = Portal::District.find(:all, :include => :schools)
    @portal_grades = Portal::Grade.active
    @default_grade_id = @portal_grades.detect { |g| g.name == '9' }.id
    @domains = Domain.all
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @portal_teacher }
    end
  end

  # GET /portal_teachers/1/edit
  def edit
    @portal_teacher = Portal::Teacher.find(params[:id])
    @user = @portal_teacher.user
  end

  # POST /portal_teachers
  # POST /portal_teachers.xml
  def create
    @portal_school = Portal::School.find(params[:school][:id])
    @portal_grade = Portal::Grade.find(params[:grade][:id])
    @domain = Domain.find(params[:domain][:id])

    @user = User.new(params[:user])
    if @user && @user.valid?
      @user.register!
      @user.save
    end
    
    @portal_teacher = Portal::Teacher.new do |t|
      t.user = @user
      t.domain = @domain
      t.schools << @portal_school
      t.grades << @portal_grade
    end
    
    if @user.errors.empty? && @portal_teacher.save
      # will redirect:
      successful_creation(@user)    
    else 
      # will redirect:
      failed_creation
    end
    
  end

  # PUT /portal_teachers/1
  # PUT /portal_teachers/1.xml
  def update
    @portal_teacher = Portal::Teacher.find(params[:id])

    respond_to do |format|
      if @portal_teacher.update_attributes(params[:teacher])
        flash[:notice] = 'Portal::Teacher was successfully updated.'
        format.html { redirect_to(@portal_teacher) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @portal_teacher.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /portal_teachers/1
  # DELETE /portal_teachers/1.xml
  def destroy
    @portal_teacher = Portal::Teacher.find(params[:id])
    @portal_teacher.destroy

    respond_to do |format|
      format.html { redirect_to(portal_teachers_url) }
      format.xml  { head :ok }
    end
  end
  
  def successful_creation(user)
    flash[:notice] = "Thanks for signing up!"
    flash[:notice] << " We're sending you an email with your activation link."
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
