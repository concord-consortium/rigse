require 'uri'
class Portal::StudentsController < ApplicationController
  include RestrictedPortalController

  # PUNDIT_CHECK_FILTERS
  before_filter :manager_or_researcher, :only => [ :show ]

  public

  def status
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::Student
    # authorize @student
    # authorize Portal::Student, :new_or_create?
    # authorize @student, :update_edit_or_destroy?
    result = Portal::Student.find(params[:id]).status(params[:offerings_updated_after] || 0)
    respond_to do |format|
      format.xml { render :xml => result }
      format.json { render :json => result }
    end
  end

  def index
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::Student
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (did not find instance)
    # @students = policy_scope(Portal::Student)
    @portal_students = Portal::Student.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @portal_students }
    end
  end

  # GET /portal_students/1
  # GET /portal_students/1.xml
  def show
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @student
    @portal_student = Portal::Student.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @portal_student }
    end
  end

  # GET /portal_students/new
  # GET /portal_students/new.xml
  def new
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::Student
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
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @student
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
  # FIXME there is a lot of logic in here that uses :class_word to indicate this is a student
  # registering themselves.  That makes it confusing and things break when the clazz_word is
  # not used when registering students.  It is also unsafe because a student could just signup
  # to a class if they new the class id
  #
  # POST /portal_students
  # POST /portal_students.xml
  #
  def create
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::Student
    @portal_clazz = find_clazz_from_params
    @grade_level = view_context.find_grade_level(params)
    user_attributes = generate_user_attributes_from_params
    @user = User.new(user_strong_params(user_attributes))
    errors = []
    if @portal_clazz.nil?
      errors << [:class_word, "must be a valid class word."]
    end
    # Only do this check if the student is signing themselves up. Everything else will work silently if these values are not set.
    if current_settings.use_student_security_questions && params[:clazz] &&params[:clazz][:class_word]
      @security_questions = SecurityQuestion.make_questions_from_hash_and_user(params[:security_questions])
      sq_errors = SecurityQuestion.errors_for_questions_list!(@security_questions)
      if sq_errors && sq_errors.size > 0
        errors << [:security_questions, " have errors: #{sq_errors.join(',')}"]
      end
    end

    # Only do this check if the student is signing themselves up.
    if current_settings.require_user_consent? && params[:clazz] && params[:clazz][:class_word]
      if params[:user][:of_consenting_age]
        @user.asked_age = true
      else
        errors << [:you, "must specify your age."]
      end
    end
    # TODO: This creation logic should be reorganized a la Portal::Teachers, so orphan Users don't get
    # created and fill up the usernamespace if there's an error later in the process. -- Cantina-CMH 6/17/10

    # Validate the user before trying to save it. Security questions are part of the user, but
    # are validated separately, so we should validate both before we save anything.
    if @user.valid? && errors.length < 1
      # temporarily disable sending email notifications for state change events
      @user.skip_notifications = true
      @user.save!
      user_created = @user.save
      if user_created
        @user.confirm!
        if current_settings.allow_default_class || @grade_level.nil?
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
          @user.update_security_questions!(@security_questions) if current_settings.use_student_security_questions
          format.html { redirect_to thanks_for_sign_up_url(:type=>"student",:login=>"#{@portal_student.user.login}") }
        else
          msg = <<-EOF
          You have successfully registered #{@user.name} with the username <span class="big">#{@user.login}</span>.
          <br/>
          EOF
          flash['info'] = msg.html_safe
          format.html { redirect_to(@portal_clazz) }
        end
      else  # something didn't get created or referenced correctly
        @portal_student = Portal::Student.new unless @portal_student
        @user = User.new unless @user
        errors.each do |e|
          @user.errors.add(e[0],e[1]);
        end
        if params[:clazz] && params[:clazz][:class_word]
          if current_settings.use_student_security_questions
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
  end

  # Commented out as a test to see if it is used
  #
  # # PUT /portal_students/1
  # # PUT /portal_students/1.xml
  # def update
  #   # PUNDIT_REVIEW_AUTHORIZE
  #   # PUNDIT_CHECK_AUTHORIZE (did not find instance)
  #   # authorize @student
  #   @portal_student = Portal::Student.find(params[:id])
  #   respond_to do |format|
  #     if @portal_student.update_attributes(portal_student_strong_params(params[:portal_student]))
  #       flash['notice'] = 'Portal::Student was successfully updated.'
  #       format.html { redirect_to(@portal_student) }
  #       format.xml  { head :ok }
  #     else
  #       format.html { render :action => "edit" }
  #       format.xml  { render :xml => @portal_student.errors, :status => :unprocessable_entity }
  #     end
  #     class_word = params[:clazz][:class_word]
  #     if class_word
  #       @portal_student.process_class_word(class_word)
  #     end
  #   end
  # end

  def move
    if request.get?
      @portal_student = Portal::Student.find(params[:id])
    else
      portal_student = Portal::Student.find(params[:id])
      current_class = Portal::Clazz.find_by_class_word(params[:clazz][:current_class_word])
      new_class = Portal::Clazz.find_by_class_word(params[:clazz][:new_class_word])

      portal_student.remove_clazz(current_class)
      portal_student.add_clazz(new_class)

      # post data to report service, include bearer token in request
      config = portal_student.move_student_and_return_config(new_class, current_class)
      ExternalReport.where('move_students_api_url LIKE "http%"').find_each{ |report|
        auth_token = 'Bearer %s' % report.move_students_api_token
        response = HTTParty.post(report.move_students_api_url,
          body: config.to_json,
          headers: {
            'Content-Type' => 'application/json',
            'Authorization' => auth_token
          },
          format: :json)

        #FIXME: We should do somethign with the response code -- if response.code == 200 # successful

      }

      flash['notice'] = 'Successfully moved student to new class.'
      redirect_to(portal_student)
    end
  end

  # DELETE /portal_students/1
  # DELETE /portal_students/1.xml
  def destroy
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @student
    @portal_student = Portal::Student.find(params[:id])
    @portal_student.destroy

    respond_to do |format|
      format.html { redirect_to(portal_students_url) }
      format.xml  { head :ok }
    end
  end

  def ask_consent
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::Student
    # authorize @student
    # authorize Portal::Student, :new_or_create?
    # authorize @student, :update_edit_or_destroy?
    @portal_student = Portal::Student.find(params[:id])
    @user = @portal_student.user
  end

  def update_consent
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::Student
    # authorize @student
    # authorize Portal::Student, :new_or_create?
    # authorize @student, :update_edit_or_destroy?
    @portal_student = Portal::Student.find(params[:id])
    @portal_student.user.asked_age = true;
    @portal_student.save
    if @portal_student.user.update_attributes(portal_student_strong_params(params[:user]))
      redirect_to root_path
    else
      render :action => "ask_consent"
    end
  end

  # GET /portal_students/signup
  # GET /portal_students/signup.xml
  def signup
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::Student
    # authorize @student
    # authorize Portal::Student, :new_or_create?
    # authorize @student, :update_edit_or_destroy?
    @portal_student = Portal::Student.new
    @security_questions = SecurityQuestion.fill_array
    @user = User.new
    respond_to do |format|
      format.html
      format.xml  { render :xml => @portal_student }
    end
  end

  def register
    @student = Portal::Student.new
    respond_to do |format|
      format.html { render :action => 'register' }
    end
  end

  def move_confirm
    @current_class_word = params[:clazz][:current_class_word]
    @new_class_word = params[:clazz][:new_class_word]
    @current_class = Portal::Clazz.find_by_class_word(@current_class_word)
    @new_class = Portal::Clazz.find_by_class_word(@new_class_word)
    @portal_student = Portal::Student.find(params[:id])
    @potentially_orphaned_assignments = []
    @show_msg = 'invalid'

    @invalid_error = check_clazzes(@current_class, @new_class)
    if @invalid_error == ''
      @potentially_orphaned_assignments = check_assignments(@new_class, @portal_student)
      @show_msg = 'move_confirmation'
    end
  end

  protected

  def check_clazzes(current_class, new_class)
    @error = ''
    if current_class.nil? || new_class.nil?
      @error = 'One or more of the class words you entered is invalid. Please try again.'
    elsif @portal_student.has_clazz?(new_class)
      @error = 'The student is already in the class you are trying to move them to. Please check the class words you are using and try again.'
    elsif !@portal_student.has_clazz?(current_class)
      @error = 'The student is not in the class you are trying to move them from. Please check the class words you are using and try again.'
    end
    @error
  end

  def check_assignments(new_class, portal_student)
    @potentially_orphaned_assignments = []
    # find learners from old class that have no corresponding assignments in new class
    @portal_student.learners.each do |sa|
      @new_class.offerings.each do |nca|
        if sa.offering.runnable == nca.runnable
          @match_found = true
        end
      end
      if !@match_found
        @potentially_orphaned_assignments << sa.offering.name
      end
    end
    @potentially_orphaned_assignments
  end

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

  def generate_user_attributes_from_params
    user_attributes = params[:user]
    user_attributes[:login] = Portal::Student.generate_user_login(user_attributes[:first_name], user_attributes[:last_name])
    user_attributes[:email] = Portal::Student.generate_user_email
    user_attributes
  end

  def portal_student_strong_params(params)
    params && params.permit(:grade_level_id, :user_id)
  end

  def user_strong_params(params)
    params && params.permit(:first_name, :last_name, :email, :login, :password, :password_confirmation)
  end

end
