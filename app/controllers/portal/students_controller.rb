class Portal::StudentsController < ApplicationController
  # GET /portal_students
  # GET /portal_students.xml
  def index
    @portal_students = Portal::Student.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @portal_students }
    end
  end

  # GET /portal_students/1
  # GET /portal_students/1.xml
  def show
    @portal_student = Portal::Student.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @portal_student }
    end
  end

  # GET /portal_students/new
  # GET /portal_students/new.xml
  def new
    @portal_student = Portal::Student.new
    @user = User.new
    if params[:clazz_id]
      @portal_clazz = Portal::Clazz.find(params[:clazz_id])
    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @portal_student }
    end
  end

  # GET /portal_students/1/edit
  def edit
    @portal_student = Portal::Student.find(params[:id])
    @user = @portal_student.user
  end

  #
  # To create a portal_student we need:
  # * information to create a new user or a reference to an existing user
  # Normally this is combined with a clazz or a token for finding a class.
  # When a student self-registers they are given the option of providing a 'class_word'.
  # A 'class_word' is a token which can be used to find a specific class.
  # If a 'class_word' is not provided then other params must be provided that
  # can be used to find an existing portal_clazz.
  # In addition a grade_level needs to be generated.
  #
  # If everything gets created or referenced correctly a Portal::StudentClass is generated.
  #
  # POST /portal_students
  # POST /portal_students.xml
  #
  def create
    @portal_clazz = find_clazz_from_params
    @grade_level = find_grade_level_from_params
    user_attributes = generate_user_attributes_from_params
    @user = User.new(user_attributes)

    # temporarily disable sending email notifications for state change events
    @user.skip_notifications = true
    @user.register!
    user_created = @user.save
    if user_created
      @user.activate!
      @portal_student = Portal::Student.create(:user_id => @user.id, :grade_level_id => @grade_level.id)
    end
    respond_to do |format|
      if user_created && @portal_clazz && @portal_student && @grade_level
        @portal_student.student_clazzes.create!(:clazz_id => @portal_clazz.id, :student_id => @portal_student.id, :start_time => Time.now)
        if params[:clazz][:class_word]
          format.html { render 'signup_success' }
        else
          format.html { redirect_to(@portal_clazz) }
        end
      else  # something didn't get created or referenced correctly
        @portal_student = Portal::Student.new unless @portal_student
        @user = User.new unless @user
        if params[:clazz][:class_word]
          format.html { render :action => "signup" }
          format.xml  { render :xml => @portal_student.errors, :status => :unprocessable_entity }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @portal_student.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # respond_to do |format|
    #   if success
    #     flash[:notice] = 'Student was successfully created.'
    #     if @portal_clazz
    #       if params[:clazz][:class_word]
    #         format.html { render 'signup_success' }
    #       else
    #         format.html { redirect_to(@portal_clazz) }
    #       end
    #     else
    #       format.html { redirect_to(@student) }
    #     end
    #     format.xml  { render :xml => @student, :status => :created, :location => @student }
    #   else
    #     if ! @student
    #       @student = Portal::Student.new
    #     end
    #     if params[:clazz][:class_word]
    #       format.html { render :action => "signup" }
    #     else
    #       format.html { render :action => "new" }
    #     end
    #     format.xml  { render :xml => @student.errors, :status => :unprocessable_entity }
    #   end
    # end
  end

  # PUT /portal_students/1
  # PUT /portal_students/1.xml
  def update
    @portal_student = Portal::Student.find(params[:id])
    respond_to do |format|
      if @portal_student.update_attributes(params[:portal_student])
        flash[:notice] = 'Portal::Student was successfully updated.'
        format.html { redirect_to(@portal_student) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @portal_student.errors, :status => :unprocessable_entity }
      end
      class_word = params[:clazz][:class_word]
      if class_word
        @portal_student.process_class_word(class_word)
      end
    end
  end

  # DELETE /portal_students/1
  # DELETE /portal_students/1.xml
  def destroy
    @portal_student = Portal::Student.find(params[:id])
    @portal_student.destroy

    respond_to do |format|
      format.html { redirect_to(portal_students_url) }
      format.xml  { head :ok }
    end
  end
  
  # GET /portal_students/signup
  # GET /portal_students/signup.xml
  def signup
    @portal_student = Portal::Student.new
    @user = User.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @portal_student }
    end
  end
  
  protected
  
  def find_clazz_from_params
    # check the multitude of ways that a class might have been passed in
    clazz = case
    when params[:clazz_id] then
      Portal::Clazz.find(params[:clazz_id])
    when params[:class_word] then
      Portal::Clazz.find_by_class_word(params[:class_word])
    when params[:clazz] && params[:clazz][:id] then
      Portal::Clazz.find(params[:clazz][:id])
    when params[:clazz][:class_word] then
      Portal::Clazz.find_by_class_word(params[:clazz][:class_word])
    else
      raise 'no class specified'
    end
    clazz
  end
  
  def find_grade_level_from_params
    grade_level = Portal::GradeLevel.find_by_name('9')
    if course = @clazz.course
      grade_levels = course.grade_levels
      grade_level = grade_levels[0] if grade_levels[0]
    else teacher = @clazz.teacher
      grade_levels = teacher.grade_levels
      grade_level = grade_levels[0] if grade_levels[0]
    end
    grade_level
  end
  
  def generate_user_attributes_from_params
    user_attributes = params[:user]
    user_attributes[:login] = Portal::Student.generate_user_login(user_attributes[:first_name], user_attributes[:last_name])
    user_attributes[:email] = Portal::Student.generate_user_email
    user_attributes
  end
  
end
