class Portal::TeachersController < ApplicationController
  include RestrictedPortalController
  public
  
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
    
    # TODO: We dont use domains or grades for teachers anymore.
    load_domains_and_grades
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
    portal_school = Portal::School.find_by_id(params[:school][:id])
    
    # TODO: Teachers DO NOT HAVE grades or Domains.
    @portal_grade = nil
    if params[:grade]
      @portal_grade = Portal::Grade.find(params[:grade][:id])
    end
    @domain = nil
    if params[:domain]
      @domain = RiGse::Domain.find(params[:domain][:id])
    end
    load_domains_and_grades

    @user = User.new(params[:user])
    #if @user && @user.valid?
    #  @user.register!
    #  @user.save
    #end
        
    @portal_teacher = Portal::Teacher.new do |t|
      t.user = @user
      t.domain = @domain
      t.schools << portal_school if !portal_school.nil?
      t.grades << @portal_grade if !@portal_grade.nil?
    end
    
    #if @user.errors.empty? && @portal_teacher.save
    if @user.valid? && @portal_teacher.valid? && !portal_school.nil?
      if @user.register! && @portal_teacher.save
      # will redirect:
        successful_creation(@user)
        return
      end
    end

    # Luckily, ActiveRecord errors allow you to attach errors to arbitrary, non-existant attributes
    # will redirect:
    @user.errors.add(:you, "must select a school") if portal_school.nil?
    failed_creation
    
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
    # Render the UsersController#thanks page instead of showing a flash message.
    render :template => 'users/thanks'
  end
  
  def failed_creation(message = 'Sorry, there was an error creating your account')
    # force the current_user to anonymous, because we have not successfully created an account yet.
    # edge case, which we might need a more integrated solution for??
    self.current_user = User.anonymous
    flash.now[:error] = message
    render :action => :new
  end
  
  
  private 
  def load_domains_and_grades
    # @portal_districts = Portal::District.virtual + Portal::District.real
    # Maybe this easier, and cleaner:
    @portal_districts = Portal::District.find(:all, :order => :name)
    @portal_grades = Portal::Grade.active
    if (@portal_grades && @portal_grades.size > 1)
      @default_grade_id = @portal_grades.last.id
    end
    @domains = RiGse::Domain.all
  end
  
  
  
end
