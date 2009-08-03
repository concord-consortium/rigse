class Portal::StudentsController < ApplicationController
  # GET /portal_students
  # GET /portal_students.xml
  def index
    @students = Portal::Student.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @students }
    end
  end

  # GET /portal_students/1
  # GET /portal_students/1.xml
  def show
    @student = Portal::Student.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @student }
    end
  end

  # GET /portal_students/new
  # GET /portal_students/new.xml
  def new
    @student = Portal::Student.new
    @user = User.new
    if params[:clazz_id]
      @clazz = Portal::Clazz.find(params[:clazz_id])
    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @student }
    end
  end

  # GET /portal_students/1/edit
  def edit
    @student = Portal::Student.find(params[:id])
    @user = @student.user
  end

  # POST /portal_students
  # POST /portal_students.xml
  def create
    success = false
    begin
      user_params = params[:user]
      user_params[:login] = Portal::Student.generate_user_login(user_params[:first_name], user_params[:last_name])
      user_params[:email] = Portal::Student.generate_user_email
      @user = User.new(user_params)
      # temporarily disable sending email notifications for state change events
      @user.skip_notifications = true
      @user.register!
      @user.save!
      @user.activate!
      
      # check the multitude of ways that a class might have been passed in
      if params[:clazz_id]
        @clazz = Portal::Clazz.find(params[:clazz_id])
      elsif params[:class_word]
        @clazz = Portal::Clazz.find_by_class_word(params[:class_word])
      elsif params[:clazz]
        if params[:clazz][:id]
          @clazz = Portal::Clazz.find(params[:clazz][:id])
        elsif params[:clazz][:class_word]
          @clazz = Portal::Clazz.find_by_class_word(params[:clazz][:class_word])
        end
      end

      grade_level = Portal::GradeLevel.find_by_name('9')
      if course = @clazz.course
        grade_levels = course.grade_levels
        grade_level = grade_levels[0] if grade_levels[0]
      elsif teacher = @clazz.teacher
        grade_levels = teacher.grade_levels
        grade_level = grade_levels[0] if grade_levels[0]
      end

      @student = Portal::Student.create!(:user_id => @user.id, :grade_level_id => grade_level.id)

      if @student.save && @clazz
        @student.student_clazzes.create!(:clazz_id => @clazz.id, :student_id => @student.id, :start_time => Time.now)
      end
      
      success = true
    rescue => e
      logger.warn("Failed to create Student: #{e}\n#{e.backtrace.join("\n")}")
    end
    respond_to do |format|
      if success
        flash[:notice] = 'Student was successfully created.'
        if @clazz
          if params[:clazz][:class_word]
            format.html { render 'signup_success' }
          else
            format.html { redirect_to(@clazz) }
          end
        else
          format.html { redirect_to(@student) }
        end
        format.xml  { render :xml => @student, :status => :created, :location => @student }
      else
        if ! @student
          @student = Portal::Student.new
        end
        if params[:clazz][:class_word]
          format.html { render :action => "signup" }
        else
          format.html { render :action => "new" }
        end
        format.xml  { render :xml => @student.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /portal_students/1
  # PUT /portal_students/1.xml
  def update
    @student = Portal::Student.find(params[:id])

    respond_to do |format|
      if @student.update_attributes(params[:student])
        flash[:notice] = 'Portal::Student was successfully updated.'
        format.html { redirect_to(@student) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @student.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /portal_students/1
  # DELETE /portal_students/1.xml
  def destroy
    @student = Portal::Student.find(params[:id])
    @student.destroy

    respond_to do |format|
      format.html { redirect_to(portal_students_url) }
      format.xml  { head :ok }
    end
  end
  
  # GET /portal_students/signup
  # GET /portal_students/signup.xml
  def signup
    @student = Portal::Student.new
    @user = User.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @student }
    end
  end 
end
