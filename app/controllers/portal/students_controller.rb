class Portal::StudentsController < ApplicationController

  include RestrictedPortalController
  public

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
    errors = []
    if @portal_clazz.nil?
      errors << [:class_word, "must be a valid class word."]
    end
    # Only do this check if the student is signing themselves up. Everything else will work silently if these values are not set.
    if current_project.use_student_security_questions && params[:clazz] &&params[:clazz][:class_word]
      @security_questions = SecurityQuestion.make_questions_from_hash_and_user(params[:security_questions])
      sq_errors = SecurityQuestion.errors_for_questions_list!(@security_questions)
      if sq_errors && sq_errors.size > 0
        errors << [:security_questions, " have errors: #{sq_errors.join(',')}"]
      end
    end

    # TODO: This creation logic should be reorganized a la Portal::Teachers, so orphan Users don't get
    # created and fill up the usernamespace if there's an error later in the process. -- Cantina-CMH 6/17/10

    # Validate the user before trying to save it. Security questions are part of the user, but
    # are validated separately, so we should validate both before we save anything.
    if @user.valid? && errors.length < 1
      # temporarily disable sending email notifications for state change events
      @user.skip_notifications = true
      @user.register!
      user_created = @user.save
      if user_created
        @user.activate!
        if current_project.allow_default_class
          @portal_student = Portal::Student.create(:user_id => @user.id)
        else
          @portal_student = Portal::Student.create(:user_id => @user.id, :grade_level_id => @grade_level.id)
        end
      end
    end
    respond_to do |format|
      if user_created && @portal_clazz && @portal_student #&& @grade_level
        @portal_student.student_clazzes.create!(:clazz_id => @portal_clazz.id, :student_id => @portal_student.id, :start_time => Time.now)

        if params[:clazz] && params[:clazz][:class_word]
          # Attach the security questions here. We don't want to bother if there was a problem elsewhere.
          @user.update_security_questions!(@security_questions) if current_project.use_student_security_questions

          format.html { render 'signup_success' }
        else
          flash[:info] = <<-EOF
            You have successfully registered #{@user.name} with the username <span class="big">#{@user.login}</span>.
            <br/>
          EOF
          format.html { redirect_to(@portal_clazz) }
        end
      else  # something didn't get created or referenced correctly
        @portal_student = Portal::Student.new unless @portal_student
        @user = User.new unless @user
        errors.each do |e|
          @user.errors.add(e[0],e[1]);
        end
        if params[:clazz] && params[:clazz][:class_word]
          if current_project.use_student_security_questions
            @security_questions = SecurityQuestion.fill_array(@security_questions)
          end
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
    @security_questions = SecurityQuestion.fill_array
    @user = User.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @portal_student }
    end
  end

  def register
    if request.post?
      @portal_clazz = find_clazz_from_params
      class_word = params[:clazz][:class_word]
      if @portal_clazz && class_word && ! current_user.anonymous?
        @student = current_user.portal_student
        if ! @student
          @grade_level = find_grade_level_from_params
          @student = Portal::Student.create(:user_id => current_user.id, :grade_level_id => @grade_level.id)
        end
        @student.process_class_word(class_word)
      else
        if current_user.anonymous?
          flash[:error] = "You must be logged in to sign up for a class!"
        else
          flash[:error] = "The class word you provided was not valid! Please check with your teacher to ensure you have the correct word."
        end
      end
      respond_to do |format|
        if (@portal_clazz && @student)
          flash[:notice] = 'Successfully registered for class.'
          format.html { redirect_to(@student) }
        else
          @student = Portal::Student.new
          format.html { render :action => 'register' }
        end
      end
    else
      @student = Portal::Student.new
      respond_to do |format|
        format.html { render :action => 'register' }
      end
    end
  end

  def confirm
    @portal_clazz = find_clazz_from_params
    if @portal_clazz.nil?
      render :update do |page|
        page.remove "invalid_word"
        page.insert_html :top, "word_form", "<p id='invalid_word' style='display:none;'>Please enter a valid class word and try again.</p>"
        page.visual_effect :BlindDown, "invalid_word", :duration => 1
      end
      return
    end
    @class_word = params[:clazz][:class_word]
    render :update do |page|
      page.remove "invalid_word"
      page.insert_html :top, "word_form", :partial => "confirmation",
        :locals => {:class_word => @class_word,
                    :clazz      => @portal_clazz,
                    :portal_student => Portal::Student.new}
      page.visual_effect :BlindDown, "confirmation", :duration => 1
    end
  end

  protected

  def find_clazz_from_params
    # check the multitude of ways that a class might have been passed in
   @portal_clazz  = case
    when params[:clazz_id] then
      Portal::Clazz.find(params[:clazz_id])
    when params[:class_word] then
      Portal::Clazz.find_by_class_word(params[:class_word])
    when params[:clazz] && params[:clazz][:id] then
      Portal::Clazz.find(params[:clazz][:id])
    when params[:clazz] && params[:clazz][:class_word] then
      Portal::Clazz.find_by_class_word(params[:clazz][:class_word])
    else
      #raise 'no class specified'
      # If no class is specified, assume default class to be used
      Portal::Clazz.default_class
    end
   @portal_clazz
  end

  def find_grade_level_from_params
    grade_level = Portal::GradeLevel.find_by_name('9')
    if @portal_clazz
      # Try to get a grade level from the class first.
      if (!(grade_levels = @portal_clazz.grade_levels).nil? && grade_levels.size > 0)
        grade_level = grade_levels[0] if grade_levels[0]
      elsif (@portal_clazz.course && @portal_clazz.course.grade_levels && @portal_clazz.course.grade_levels.size > 0)
        course = @portal_clazz.course
        grade_levels = course.grade_levels
        grade_level = grade_levels[0] if grade_levels[0]
      elsif @portal_clazz.teacher
        grade_levels = @portal_clazz.teacher.grade_levels
        grade_level = grade_levels[0] if grade_levels[0]
      end
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
