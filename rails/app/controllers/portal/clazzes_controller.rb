class Portal::ClazzesController < ApplicationController

  # TODO:  There need to be a lot more
  # controller filters here...
  # this only protects management actions:
  include RestrictedPortalController


  # PUNDIT_CHECK_FILTERS
  before_action :teacher_admin, :only => [:class_list, :edit]
  before_action :student_teacher_admin, :only => [:show]

  #
  # Check that the current teacher owns the class they are
  # accessing.
  #
  include RestrictedTeacherController
  before_action :check_teacher_owns_clazz, :only => [   :roster,
                                                        :materials,
                                                        :fullstatus ]

  def current_clazz
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::Clazz
    # authorize @clazz
    # authorize Portal::Clazz, :new_or_create?
    # authorize @clazz, :update_edit_or_destroy?
    Portal::Clazz.find(params[:id])
  end

  public
  # GET /portal_clazzes
  # GET /portal_clazzes.xml
  def index
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::Clazz
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (did not find instance)
    # @clazzes = policy_scope(Portal::Clazz)
    @portal_clazzes = Portal::Clazz.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @portal_clazzes }
    end
  end

  # GET /portal_clazzes/1
  # GET /portal_clazzes/1.xml
  def show
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @clazz
    @portal_clazz = Portal::Clazz.where(id: params[:id]).includes([:teachers, { :offerings => [:learners, :open_responses, :multiple_choices] }]).first
    @portal_clazz.refresh_saveable_response_objects
    @teacher = @portal_clazz.parent
    if current_settings.allow_default_class
      @offerings = @portal_clazz.offerings_with_default_classes(current_visitor)
    else
      @offerings = @portal_clazz.offerings
    end

    # Save the left pane sub-menu item
    Portal::Teacher.save_left_pane_submenu_item(current_visitor, Portal::Teacher.LEFT_PANE_ITEM['NONE'])

    if current_user.portal_teacher
      redirect_to(action: 'materials') and return
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml {render :xml => @portal_clazz}
    end
  end

  # GET /portal_clazzes/new
  # GET /portal_clazzes/new.xml
  def new
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::Clazz
    @portal_clazz = Portal::Clazz.new
    if params[:teacher_id]
      @portal_clazz.teacher = Portal::Teacher.find(params[:teacher_id])
    elsif current_visitor.portal_teacher
      @portal_clazz.teacher = current_visitor.portal_teacher
      @portal_clazz.teacher_id = current_visitor.portal_teacher.id
    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @portal_clazz }
    end
  end

  # GET /portal_clazzes/1/edit
  def edit
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @clazz
    @portal_clazz = Portal::Clazz.find(params[:id])

    # Save the left pane sub-menu item
    Portal::Teacher.save_left_pane_submenu_item(current_visitor, Portal::Teacher.LEFT_PANE_ITEM['CLASS_SETUP'])

  end

  # POST /portal_clazzes
  # POST /portal_clazzes.xml
  def create
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::Clazz

    @object_params = params[:portal_clazz]
    school_id = @object_params.delete(:school)
    grade_levels = @object_params.delete(:grade_levels)

    if !valid_school_id_param?(school_id)
      school_id = nil
    end
    if !valid_grade_levels_param?(grade_levels)
      grade_levels = nil
    end

    @portal_clazz = Portal::Clazz.new(portal_clazz_strong_params(@object_params))

    okToCreate = true
    if !school_id
      # This should never happen, since the schools dropdown should consist of the default site school if the current user has no schools
      flash['error'] = "You need to belong to a school in order to create classes. Please join a school and try again."
      okToCreate = false
    end

    if current_visitor.anonymous?
      flash['error'] = "Anonymous can't create classes. Please log in and try again."
      okToCreate = false
    end

    if okToCreate and Admin::Settings.default_settings.enable_grade_levels?
      grade_levels.each do |name, v|
        grade = Portal::Grade.where(name: name).first_or_create
        @portal_clazz.grades << grade if grade
      end if grade_levels
      if @portal_clazz.grades.empty?
        flash['error'] = "You need to select at least one grade level for this class."
        okToCreate = false
      end
    end

    if okToCreate && !@portal_clazz.teacher
      if current_visitor.portal_teacher
        @portal_clazz.teacher_id = current_visitor.portal_teacher.id
        @portal_clazz.teacher = current_visitor.portal_teacher
      else
        teacher = Portal::Teacher.create(:user => current_visitor) # Former call set :user_id directly; class validations didn't like that
        if teacher && teacher.id # Former call used .id directly on create method, leaving room for NilClass error
          @portal_clazz.teacher_id = teacher.id # Former call tried to do another Portal::Teacher.create. We don't want to double-create this teacher
          @portal_clazz.teacher = teacher
          @portal_clazz.teacher.schools << Portal::School.find_by_name(APP_CONFIG[:site_school])
        else
          flash['error'] = "There was an error trying to associate you with this class. Please try again."
          okToCreate = false
        end
      end
    end

    if okToCreate
      # We can't use Course.find_or_create_by_course_number_name_and_school_id here, because we don't know what course_number we're looking for
      course = Portal::Course.find_by_name_and_school_id(@portal_clazz.name, school_id)
      course = Portal::Course.create({
        :name => @portal_clazz.name,
        :course_number => nil,
        :school_id => school_id
      }) if course.nil?

      if course
        # This will finally tie this clazz to a course and a school
        @portal_clazz.course = course
      else
        flash['error'] = "There was an error trying to create your new class. Please try again."
        okToCreate = false
      end
    end

    respond_to do |format|
      if okToCreate && @portal_clazz.save
        # send email notifications about class creation
        Portal::ClazzMailer.clazz_creation_notification(@current_user, @portal_clazz).deliver

        flash['notice'] = 'Class was successfully created.'
        format.html { redirect_to(url_for([:materials, @portal_clazz])) }
        format.xml  { render :xml => @portal_clazz, :status => :created, :location => @portal_clazz }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @portal_clazz.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /portal_clazzes/1
  # PUT /portal_clazzes/1.xml
  def update
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @clazz
    @portal_clazz = Portal::Clazz.find(params[:id])

    object_params = params[:portal_clazz]
    grade_levels = object_params.delete(:grade_levels)
    if !valid_grade_levels_param?(grade_levels)
      grade_levels = nil
    end
    if grade_levels
      # This logic will attempt to prevent someone from removing all grade levels from a class.
      grades_to_add = []
      grade_levels.each do |name, v|
        grade = Portal::Grade.find_by_name(name)
        grades_to_add << grade if grade
      end
      object_params[:grades] = grades_to_add if !grades_to_add.empty?
    end

    new_teacher_ids = (object_params.delete(:current_teachers) || '').split(',').map {|id| id.to_i}

    update_teachers = -> {
      update_report_model_cache = false

      current_teacher_ids = @portal_clazz.teachers.map {|t| t.id}
      new_teacher_ids.each do |new_teacher_id|
        if !current_teacher_ids.include?(new_teacher_id)
          teacher = Portal::Teacher.find_by_id(new_teacher_id)
          if teacher
            teacher.add_clazz(@portal_clazz)
            update_report_model_cache = true
          end
        end
      end
      current_teacher_ids.each do |current_teacher_id|
        if !new_teacher_ids.include?(current_teacher_id)
          teacher = Portal::Teacher.find_by_id(current_teacher_id)
          if teacher
            teacher.remove_clazz(@portal_clazz)
            update_report_model_cache = true
          end
        end
      end

      # if the teachers change we need to update the report model cache so they are reported correctly
      if update_report_model_cache
        @portal_clazz.offerings.each do |offering|
          offering.learners.each do |learner|
            learner.update_report_model_cache()
          end
        end
      end

      @portal_clazz.reload
    }

    if request.xhr?
      if @portal_clazz.update(portal_clazz_strong_params(object_params))
        update_teachers.call
      end
      render :partial => 'show', :locals => { :portal_clazz => @portal_clazz }
    else
      respond_to do |format|
        okToUpdate = true

        if Admin::Settings.default_settings.enable_grade_levels?
          if !grade_levels
            flash['error'] = "You need to select at least one grade level for this class."
            okToUpdate = false
          end
        end

        if okToUpdate && @portal_clazz.update(portal_clazz_strong_params(object_params))
          update_teachers.call
          flash['notice'] = 'Class was successfully updated.'
          format.html { redirect_to(url_for([:materials, @portal_clazz])) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @portal_clazz.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /portal_clazzes/1
  # DELETE /portal_clazzes/1.xml
  def destroy
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @clazz
    @portal_clazz = Portal::Clazz.find(params[:id])
    @portal_clazz.destroy
    respond_to do |format|
      format.html { redirect_to(portal_clazzes_url) }
      format.js
      format.xml  { head :ok }
    end
  end

  ## END OF CRUD METHODS
  def edit_offerings
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::Clazz
    # authorize @clazz
    # authorize Portal::Clazz, :new_or_create?
    # authorize @clazz, :update_edit_or_destroy?
    @portal_clazz = Portal::Clazz.find(params[:id])
  end

  # GET /portal_clazzes/1/class_list
  def class_list
    @portal_clazz = Portal::Clazz.find_by_id(params[:id])

    respond_to do |format|
      format.html { render :layout => 'report'}
    end
  end

  # GET /portal_clazzes/1/roster
  def roster
    @portal_clazz = Portal::Clazz.find(params[:id])

    # Save the left pane sub-menu item
    Portal::Teacher.save_left_pane_submenu_item(current_visitor, Portal::Teacher.LEFT_PANE_ITEM['STUDENT_ROSTER'])
  end

  def manage_classes
    if current_user.nil? || !current_visitor.portal_teacher
      raise Pundit::NotAuthorizedError
    end
    @teacher = current_visitor.portal_teacher;
  end

  def materials
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::Clazz
    # authorize @clazz
    # authorize Portal::Clazz, :new_or_create?
    # authorize @clazz, :update_edit_or_destroy?


    @portal_clazz = Portal::Clazz.includes(:offerings => :learners, :students => :user).find(params[:id])

    # Save the left pane sub-menu item
    Portal::Teacher.save_left_pane_submenu_item(current_visitor, Portal::Teacher.LEFT_PANE_ITEM['MATERIALS'])

  end


  def sort_offerings
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::Clazz
    # authorize @clazz
    # authorize Portal::Clazz, :new_or_create?
    # authorize @clazz, :update_edit_or_destroy?
    if current_visitor.portal_teacher
      params[:clazz_offerings].each_with_index{|id,idx| Portal::Offering.update(id, :position => (idx + 1))}
    end
    head :ok
  end

  def fullstatus
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::Clazz
    # authorize @clazz
    # authorize Portal::Clazz, :new_or_create?
    # authorize @clazz, :update_edit_or_destroy?


    @portal_clazz = Portal::Clazz.find(params[:id]);

    @portal_clazz = Portal::Clazz.find_by_id(params[:id])

    # Save the left pane sub-menu item
    Portal::Teacher.save_left_pane_submenu_item(current_visitor, Portal::Teacher.LEFT_PANE_ITEM['FULL_STATUS'])
  end

  # this is used by the iSENSE interactive and app inorder to get information
  # about the class given the class_word. It does not require authorization
  # because the user needs to know the classword.
  # Most of this information is already available just by signing up as a student
  # and entering in the class word.
  def info
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::Clazz
    # authorize @clazz
    # authorize Portal::Clazz, :new_or_create?
    # authorize @clazz, :update_edit_or_destroy?
    # look up the class with the class word and return a json object
    clazz = Portal::Clazz.find_by_class_word(params[:class_word])

    if clazz
      state = nil
      if school = clazz.school
        state = school.state
      end

      render :json => {
        :uri => url_for(clazz),
        :name => clazz.name,
        :state => state,
        :teachers => clazz.teachers.map{|teacher|
          {
            :id => url_for(teacher.user),
            :first_name => teacher.user.first_name,
            :last_name => teacher.user.last_name
          }
        }
      }
    else
      render :json => {:error => "No class found"}, :status => :not_found
    end
  end

  def external_report
    portal_clazz = Portal::Clazz.find(params[:id])
    report = ExternalReport.find(params[:report_id])
    next_url = report.url_for_class(portal_clazz, current_visitor, request.protocol, request.host_with_port)
    redirect_to next_url
  end

  private

  def portal_clazz_strong_params(params)
    params && params.permit(:class_hash, :class_word, :course_id, :default_class, :description, :end_time, :logging, :name,
                            :section, :semester_id, :start_time, :status, :teacher_id)
  end

  def valid_grade_levels_param?(grade_levels_param)
    grade_levels_param.kind_of?(Array) || grade_levels_param.kind_of?(ActionController::Parameters)
  end

  def valid_school_id_param?(school_id_param)
    # check if it is an integer
    school_id_param.to_i.to_s == school_id_param
  end

end