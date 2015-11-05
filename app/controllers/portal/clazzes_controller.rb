class Portal::ClazzesController < ApplicationController

  # TODO:  There need to be a lot more
  # controller filters here...
  # this only protects management actions:
  include RestrictedPortalController


  # PUNDIT_CHECK_FILTERS
  before_filter :teacher_admin_or_config, :only => [:class_list, :edit]
  before_filter :student_teacher_admin_or_config, :only => [:show]

  def current_clazz
    Portal::Clazz.find(params[:id])
  end

  public
  # GET /portal_clazzes
  # GET /portal_clazzes.xml
  def index
    # PUNDIT_CHOOSE_AUTHORIZE
    # authorize Portal::Clazz
    @portal_clazzes = policy_scope(Portal::Clazz)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @portal_clazzes }
    end
  end

  # GET /portal_clazzes/1
  # GET /portal_clazzes/1.xml
  def show
    @portal_clazz = Portal::Clazz.find(params[:id], :include =>  [:teachers, { :offerings => [:learners, :open_responses, :multiple_choices] }])
    # PUNDIT_CHOOSE_AUTHORIZE
    # authorize @portal_clazz
    @portal_clazz.refresh_saveable_response_objects
    @teacher = @portal_clazz.parent
    if current_settings.allow_default_class
      @offerings = @portal_clazz.offerings_with_default_classes(current_visitor)
    else
      @offerings = @portal_clazz.offerings
    end

    # Save the left pane sub-menu item
    Portal::Teacher.save_left_pane_submenu_item(current_visitor, Portal::Teacher.LEFT_PANE_ITEM['NONE'])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @portal_clazz }
    end
  end

  # GET /portal_clazzes/new
  # GET /portal_clazzes/new.xml
  def new
    # PUNDIT_CHOOSE_AUTHORIZE
    # authorize Portal::Clazz
    @semesters = Portal::Semester.all
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
    @portal_clazz = Portal::Clazz.find(params[:id])
    # PUNDIT_CHOOSE_AUTHORIZE
    # authorize @portal_clazz
    @semesters = Portal::Semester.all
    if request.xhr?
      render :partial => 'remote_form', :locals => { :portal_clazz => @portal_clazz }
      return
    end

    # Save the left pane sub-menu item
    Portal::Teacher.save_left_pane_submenu_item(current_visitor, Portal::Teacher.LEFT_PANE_ITEM['CLASS_SETUP'])

  end

  # POST /portal_clazzes
  # POST /portal_clazzes.xml
  def create
    # PUNDIT_CHOOSE_AUTHORIZE
    # authorize Portal::Clazz
    @semesters = Portal::Semester.all

    @object_params = params[:portal_clazz]
    school_id = @object_params.delete(:school)
    grade_levels = @object_params.delete(:grade_levels)

    @portal_clazz = Portal::Clazz.new(@object_params)

    okToCreate = true
    if !school_id
      # This should never happen, since the schools dropdown should consist of the default site school if the current user has no schools
      flash[:error] = "You need to belong to a school in order to create classes. Please join a school and try again."
      okToCreate = false
    end

    if current_visitor.anonymous?
      flash[:error] = "Anonymous can't create classes. Please log in and try again."
      okToCreate = false
    end

    if okToCreate and Admin::Settings.default_settings.enable_grade_levels?
      grade_levels.each do |name, v|
        grade = Portal::Grade.find_or_create_by_name(name)
        @portal_clazz.grades << grade if grade
      end if grade_levels
      if @portal_clazz.grades.empty?
        flash[:error] = "You need to select at least one grade level for this class."
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
          flash[:error] = "There was an error trying to associate you with this class. Please try again."
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
        flash[:error] = "There was an error trying to create your new class. Please try again."
        okToCreate = false
      end
    end

    respond_to do |format|
      if okToCreate && @portal_clazz.save
        flash[:notice] = 'Class was successfully created.'
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
    @semesters = Portal::Semester.all
    @portal_clazz = Portal::Clazz.find(params[:id])
    # PUNDIT_CHOOSE_AUTHORIZE
    # authorize @portal_clazz

    if request.xhr?
      object_params = params[:portal_clazz]
      grade_levels = object_params.delete(:grade_levels)
      if grade_levels
        # This logic will attempt to prevent someone from removing all grade levels from a class.
        grades_to_add = []
        grade_levels.each do |name, v|
          grade = Portal::Grade.find_by_name(name)
          grades_to_add << grade if grade
        end
        object_params[:grades] = grades_to_add if !grades_to_add.empty?
      end

      @portal_clazz.update_attributes(object_params)
      render :partial => 'show', :locals => { :portal_clazz => @portal_clazz }
    else
      respond_to do |format|
        okToUpdate = true
        object_params = params[:portal_clazz]
        grade_levels = object_params.delete(:grade_levels)

        clazz_investigation_id = params[:clazz_investigations]
        clazz_investigation_id_hidden = params[:clazz_investigations_hidden]

        @portal_clazz.offerings.each do|offering|
          offering.active = false
          offering.position = clazz_investigation_id_hidden.index(offering.id.to_s) + 1
          unless clazz_investigation_id.nil? then
            if clazz_investigation_id.include?(offering.id.to_s) then
              offering.active = true
            end
          end

          offering.save

        end

        if Admin::Settings.default_settings.enable_grade_levels?
          if grade_levels
            # This logic will attempt to prevent someone from removing all grade levels from a class.
            grades_to_add = []
            grade_levels.each do |name, v|
              grade = Portal::Grade.find_by_name(name)
              grades_to_add << grade if grade
            end
            object_params[:grades] = grades_to_add if !grades_to_add.empty?
          else
            flash[:error] = "You need to select at least one grade level for this class."
            okToUpdate = false
          end
        end

        if okToUpdate && @portal_clazz.update_attributes(object_params)
          flash[:notice] = 'Class was successfully updated.'
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
    @portal_clazz = Portal::Clazz.find(params[:id])
    # PUNDIT_CHOOSE_AUTHORIZE
    # authorize @portal_clazz
    @portal_clazz.destroy
    respond_to do |format|
      format.html { redirect_to(portal_clazzes_url) }
      format.js
      format.xml  { head :ok }
    end
  end

  ## END OF CRUD METHODS
  def edit_offerings
    @portal_clazz = Portal::Clazz.find(params[:id])
    # PUNDIT_CHOOSE_AUTHORIZE
    # authorize @portal_clazz, :update_edit_or_destroy?
    @grade_span = session[:grade_span] ||= cookies[:grade_span]
    @domain_id = session[:domain_id] ||= cookies[:domain_id]
  end

  # HACK:
  # TODO: (IMPORTANT:) This  method is currenlty only for ajax requests, and uses dom_ids
  # TODO: to infer runnables. Rewrite this, so that the params are less JS/DOM specific..
  def add_offering
    @portal_clazz = Portal::Clazz.find(params[:id])
    # PUNDIT_CHOOSE_AUTHORIZE
    # authorize @portal_clazz, :update_edit_or_destroy?
    dom_id = params[:dragged_dom_id]
    container = params[:dropped_dom_id]
    runnable_id = params[:runnable_id]
    unless params[:runnable_type] == 'portal_offering'
      runnable_type = params[:runnable_type].classify
      @offering = Portal::Offering.find_or_create_by_clazz_id_and_runnable_type_and_runnable_id(@portal_clazz.id,runnable_type,runnable_id)
      if @offering.position == 0
        @offering.position = @portal_clazz.offerings.length
        @offering.save
      end
      if @offering
        if @portal_clazz.default_class == true
          if @offering.clazz.blank? || (@offering.runnable.offerings_count == 0 && @offering.clazz.default_class == true)
            @offering.default_offering = true
            @offering.save
          else
            error_msg = "The #{@offering.runnable.class.display_name} #{@offering.runnable.name} is already assigned in a class."
            @offering.destroy
            render :update do |page|
              page << "var element = $('#{dom_id}');"
              page << "element.show();"
              page << "$('flash').update('#{error_msg}');"
              page << "alert('#{error_msg}');"
            end
            return
          end
        else
          @offering.save
        end
        @portal_clazz.reload
      end
      render :update do |page|
        page << "var element = $('#{dom_id}');"
        page << "element.remove();"
        page.insert_html :bottom, container, :partial => 'shared/offering_for_teacher', :locals => {:offering => @offering}
      end
    end
    @offering.refresh_saveable_response_objects
  end


  # HACK:
  # TODO: (IMPORTANT:) This  method is currenlty only for ajax requests, and uses dom_ids
  # TODO: to infer runnables. Rewrite this, so that the params are less JS/DOM specific..
  def remove_offering
    @portal_clazz = Portal::Clazz.find(params[:id])
    # PUNDIT_CHOOSE_AUTHORIZE
    # authorize @portal_clazz, :update_edit_or_destroy?
    dom_id = params[:dragged_dom_id]
    container = params[:dropped_dom_id]
    offering_id = params[:offering_id]
    @offering = Portal::Offering.find(offering_id)
    if (@offering && @offering.can_be_deleted?)
      @runnable = @offering.runnable
      @offering.destroy
      @portal_clazz.update_offerings_position
      @portal_clazz.reload
      render :update do |page|
        page << "var container = $('#{container}');"
        page << "var element = $('#{dom_id}');"
        page << "element.remove();"
        page << "$('flash').update('');"
        page.insert_html :top, container, :partial => 'shared/runnable', :locals => {:runnable => @runnable}
      end
    else
      error_msg = "Cannot delete offering with student data. Please deactivate instead."
      render :update do |page|
        page << "var element = $('#{dom_id}');"
        page << "element.show();"
        page << "alert('#{error_msg}');"
      end
    end
  end

  # HACK: Add a student to a clazz
  # TODO: test this method
  # NOTE: delete student is in the student_clazzes_controller.
  # we should put these functions in the same place ...
  def add_student
    @student = nil
    @portal_clazz = Portal::Clazz.find(params[:id])
    # PUNDIT_CHOOSE_AUTHORIZE
    # authorize @portal_clazz, :update_edit_or_destroy?
    valid_data = false
    begin
      student_id = params[:student_id].to_i
      valid_data = true && student_id != 0
    rescue
      valid_data = false
    end

    if params[:student_id] && (!params[:student_id].empty?) && valid_data
      @student = Portal::Student.find(params[:student_id])
    end
    if @student
      @student.add_clazz(@portal_clazz)
      @portal_clazz.reload
      render :update do |page|
        page << "if ($('students_listing')){"
        page.replace_html 'students_listing', :partial => 'portal/students/table_for_clazz', :locals => {:portal_clazz => @portal_clazz}
        page << "}"
        #page << "if ($('add_students_listing')){"
        #page.replace_html 'add_students_listing', :partial => 'portal/students/current_student_list_for_clazz', :locals => {:portal_clazz => @portal_clazz}
        #page << "}"
        page << "if ($('oClassStudentCount')){"
        page.replace_html 'oClassStudentCount', @portal_clazz.students.length.to_s
        page << "}"
        page.replace 'student_add_dropdown', student_add_dropdown(@portal_clazz)
      end
    else
      render :update do |page|
        # previous message was "that was a total failure"
        # this case should not happen, but if it does, display something
        # more friendly such as:
        page << "alert('Please select a user from the list before clicking add button.')"
      end
    end
  end

  def add_teacher
    @portal_clazz = Portal::Clazz.find_by_id(params[:id])
    # PUNDIT_CHOOSE_AUTHORIZE
    # authorize @portal_clazz, :update_edit_or_destroy?

    (render(:update) { |page| page << "$('flash').update('Class not found')" } and return) unless @portal_clazz
    (render(:update) { |page| page << "$('flash').update('#{Portal::Clazz::ERROR_UNAUTHORIZED}')" } and return) unless current_visitor && @portal_clazz.changeable?(current_visitor)

    @teacher = Portal::Teacher.find_by_id(params[:teacher_id])

    (render(:update) { |page| page << "$('flash').update('Teacher not found')" } and return) unless @teacher

    begin
      @teacher.add_clazz(@portal_clazz)
      @portal_clazz.reload
      replace_html = render_to_string :partial => 'portal/teachers/list_for_clazz_setup', :locals => {:portal_clazz => @portal_clazz}
      replace_html.gsub!(/\r\n|\r|\n/, '');
      render :update do |page|
        #page.replace_html  'teachers_listing', :partial => 'portal/teachers/table_for_clazz', :locals => {:portal_clazz => @portal_clazz}
        #page.visual_effect :highlight, 'teachers_listing'
        page.replace_html  'div_teacher_list',replace_html
        page.replace 'teacher_add_dropdown', teacher_add_dropdown(@portal_clazz)
        if @teacher
          page.replace_html  'flash',''
        end
      end
    rescue
      render :update do |page|
        page << "$('flash').update('There was an error while processing your request.')"
      end
    end
  end

  def remove_teacher
    @portal_clazz = Portal::Clazz.find_by_id(params[:id])
    # PUNDIT_CHOOSE_AUTHORIZE
    # authorize @portal_clazz, :update_edit_or_destroy?
    (render(:update) { |page| page << "$('flash').update('Class not found')" } and return) unless @portal_clazz

    @teacher = @portal_clazz.teachers.find_by_id(params[:teacher_id])
    (render(:update) { |page| page << "$('flash').update('Teacher not found')" } and return) unless @teacher

    if (reason = @portal_clazz.reason_user_cannot_remove_teacher_from_class(current_visitor, @teacher))
      render(:update) { |page| page << "$('flash').update('#{reason}')" }
      return
    end

    begin
      @teacher.remove_clazz(@portal_clazz)
      @portal_clazz.reload

      if @teacher == current_visitor.portal_teacher
        flash[:notice] = "You have been successfully removed from class: #{@portal_clazz.name}"
        render(:update) { |page| page.redirect_to home_url }
      else
        # Redraw the entire table, to disable delete links as needed. -- Cantina-CMH 6/9/10
        #render(:update) { |page| page.replace_html 'teachers_listing', :partial => 'portal/teachers/table_for_clazz', :locals => {:portal_clazz => @portal_clazz} }
        replace_html = render_to_string :partial => 'portal/teachers/list_for_clazz_setup', :locals => {:portal_clazz => @portal_clazz}
        replace_html.gsub!(/\r\n|\r|\n/, '');
        render :update do|page|
          page.replace_html  'div_teacher_list',replace_html
          page.replace 'teacher_add_dropdown', teacher_add_dropdown(@portal_clazz)
        end
        return
      end

      # Former remove_teacher.js.rjs has been deleted. It was very similar to destroy.js.rjs. -- Cantina-CMH 6/9/10
      # respond_to do |format|
      #   format.js
      # end
    rescue
      render(:update) { |page| page << "$('flash').update('There was an error while processing your request.')" }
    end
  end

  def class_list
    @portal_clazz = Portal::Clazz.find_by_id(params[:id])
    # PUNDIT_CHOOSE_AUTHORIZE
    # authorize @portal_clazz, :show?

    respond_to do |format|
      format.html { render :layout => 'report'}
    end
  end

# GET /portal_clazzes/1/roster
  def roster
    unless current_visitor.portal_teacher
      redirect_to home_url
      return
    end
    @portal_clazzes = Portal::Clazz.all
    @portal_clazz = Portal::Clazz.find(params[:id])
    # PUNDIT_CHOOSE_AUTHORIZE
    # authorize @portal_clazz, :show?
    if request.xhr?
      render :partial => 'remote_form_student_roster', :locals => { :portal_clazz => @portal_clazz }
      return
    end

    # Save the left pane sub-menu item
    Portal::Teacher.save_left_pane_submenu_item(current_visitor, Portal::Teacher.LEFT_PANE_ITEM['STUDENT_ROSTER'])

  end

# GET add/edit student list
  def add_new_student_popup
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::Clazz
    # authorize @clazz
    # authorize Portal::Clazz, :new_or_create?
    # authorize @clazz, :update_edit_or_destroy?
    if request.xhr?
      @portal_student = Portal::Student.new
      @user = User.new
      render :partial => 'portal/students/form', :locals => {:portal_student => @portal_student, :portal_clazz => Portal::Clazz.find_by_id(params[:id]), :signup => false}
      #render :partial => 'portal/students/add_edit_list_for_clazz', :locals => { :portal_clazz => Portal::Clazz.find_by_id(params[:id])}
      return
    end
  end

  def manage_classes
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::Clazz
    # authorize @clazz
    # authorize Portal::Clazz, :new_or_create?
    # authorize @clazz, :update_edit_or_destroy?
    unless current_visitor.portal_teacher
      redirect_to home_url
      return
    end

    @teacher = current_visitor.portal_teacher;

    if request.put?

      # Position teacher classes
      # and
      # Activate/Deactivate teacher classes
      arrTeacherClazzPosition = params['teacher_clazz_position']

      arrActiveTeacherClazz = nil
      if (params.has_key? 'teacher_clazz')
        arrActiveTeacherClazz = params['teacher_clazz']
      else
        arrActiveTeacherClazz = []
      end

      position = 1
      arrTeacherClazzPosition.each do |teacher_clazz_id|
        teacher_clazz = Portal::TeacherClazz.find(teacher_clazz_id);
        teacher_clazz.position = position;
        if (arrActiveTeacherClazz.include?(teacher_clazz_id))
          teacher_clazz.active = true
        else
          teacher_clazz.active = false
        end
        teacher_clazz.clazz.save!
        teacher_clazz.save!
        position += 1;
      end

      render(:update) { |page|
        page.replace_html 'clazz_list_container', :partial => 'portal/clazzes/clazzes_list', :locals => {:top_node => @teacher, :selects => []}
        page.replace_html 'manage_classes_panel', :partial => 'portal/clazzes/manage_clazzes_panel', :locals => {:@teacher => @teacher}
      }
      return
    end



  end

  def copy_class
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::Clazz
    # authorize @clazz
    # authorize Portal::Clazz, :new_or_create?
    # authorize @clazz, :update_edit_or_destroy?

    response_value = {
      :success => true,
      :error_msg => nil
    }

    unless current_visitor.portal_teacher
      response_value[:success] = false
      response_value[:error_msg] = "You need to be a teacher to copy classes. Please log in as a teacher and try again."
      render :json => response_value
      return
    end

    teacher = current_visitor.portal_teacher

    class_to_copy = Portal::Clazz.find(params[:id]);

    params[:portal_clazz] = class_to_copy

    new_class = Portal::Clazz.new(
        :name => params[:clazz_name],
        :class_word => params[:clazz_word],
        :description => params[:clazz_desc],
        :grades => class_to_copy.grades,
        :teacher_id => teacher.id,
        :teacher => class_to_copy.teacher,
        :course => class_to_copy.course,
        :semester_id => class_to_copy.semester_id
    )

    class_to_copy.teachers.each do |other_teacher|
      new_class.add_teacher(other_teacher)
    end

    if(!new_class.save)
      response_value[:success] = false
      response_value[:error_msg] = new_class.errors
      render :json => response_value
      return
    end

    class_to_copy.offerings.each do |offering|
       new_offering = Portal::Offering.find_or_create_by_clazz_id_and_runnable_type_and_runnable_id(new_class.id, offering.runnable_type, offering.runnable_id)
       new_offering.status = offering.status
       new_offering.active = offering.active
       new_offering.save!
    end

    render :json => response_value

  end


  def materials
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::Clazz
    # authorize @clazz
    # authorize Portal::Clazz, :new_or_create?
    # authorize @clazz, :update_edit_or_destroy?
    unless current_visitor.portal_teacher
      redirect_to home_url
      return
    end

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
    render :nothing => true
  end

  def fullstatus
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::Clazz
    # authorize @clazz
    # authorize Portal::Clazz, :new_or_create?
    # authorize @clazz, :update_edit_or_destroy?
    unless current_visitor.portal_teacher
      redirect_to home_url
      return
    end
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
end
