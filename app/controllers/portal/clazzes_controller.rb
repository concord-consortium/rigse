class Portal::ClazzesController < ApplicationController
  
  # TODO:  There need to be a lot more 
  # controller filters here...
  # this only protects management actions:
  include RestrictedPortalController
  
  before_filter :teacher_admin_or_config, :only => [:class_list]
  
  def current_clazz
    Portal::Clazz.find(params[:id])
  end
  
  public
  # GET /portal_clazzes
  # GET /portal_clazzes.xml
  def index
    @portal_clazzes = Portal::Clazz.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @portal_clazzes }
    end
  end

  # GET /portal_clazzes/1
  # GET /portal_clazzes/1.xml
  def show
    @portal_clazz = Portal::Clazz.find(params[:id], :include =>  [:teachers, { :offerings => [:learners, :open_responses, :multiple_choices] }])
    @portal_clazz.refresh_saveable_response_objects
    @teacher = @portal_clazz.parent
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @portal_clazz }
    end
  end

  # GET /portal_clazzes/new
  # GET /portal_clazzes/new.xml
  def new
    @semesters = Portal::Semester.find(:all)
    @portal_clazz = Portal::Clazz.new
    if params[:teacher_id]
      @portal_clazz.teacher = Portal::Teacher.find(params[:teacher_id])
    elsif current_user.portal_teacher
      @portal_clazz.teacher = current_user.portal_teacher
      @portal_clazz.teacher_id = current_user.portal_teacher.id
    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @portal_clazz }
    end
  end

  # GET /portal_clazzes/1/edit
  def edit
    @portal_clazz = Portal::Clazz.find(params[:id])
    @semesters = Portal::Semester.find(:all)
    if request.xhr?
      render :partial => 'remote_form', :locals => { :portal_clazz => @portal_clazz }
    end
  end

  # POST /portal_clazzes
  # POST /portal_clazzes.xml
  def create
    @semesters = Portal::Semester.find(:all)

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
    
    if okToCreate
      grade_levels.each do |name, v|
        grade = Portal::Grade.find_by_name(name)
        @portal_clazz.grades << grade if grade
      end if grade_levels
      if @portal_clazz.grades.empty?
        flash[:error] = "You need to select at least one grade level for this class."
        okToCreate = false
      end
    end
    
    if okToCreate && !@portal_clazz.teacher
      if current_user.anonymous?
        flash[:error] = "Anonymous can't create classes. Please log in and try again."
        okToCreate = false
      elsif current_user.portal_teacher
        @portal_clazz.teacher_id = current_user.portal_teacher.id
        @portal_clazz.teacher = current_user.portal_teacher
      else
        teacher = Portal::Teacher.create(:user => current_user) # Former call set :user_id directly; class validations didn't like that
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
        format.html { redirect_to(@portal_clazz) }
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
    @semesters = Portal::Semester.find(:all)
    @portal_clazz = Portal::Clazz.find(params[:id])
    
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
        
        if okToUpdate && @portal_clazz.update_attributes(object_params)
          flash[:notice] = 'Class was successfully updated.'
          format.html { redirect_to(@portal_clazz) }
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
    @grade_span = session[:grade_span] ||= cookies[:grade_span]
    @domain_id = session[:domain_id] ||= cookies[:domain_id]
  end
  
  # HACK:
  # TODO: (IMPORTANT:) This  method is currenlty only for ajax requests, and uses dom_ids 
  # TODO: to infer runnables. Rewrite this, so that the params are less JS/DOM specific..
  def add_offering
    @portal_clazz = Portal::Clazz.find(params[:id])
    dom_id = params[:dragged_dom_id]
    container = params[:dropped_dom_id]
    runnable_id = params[:runnable_id]
    unless params[:runnable_type] == 'portal_offering'
      runnable_type = params[:runnable_type].classify
      @offering = Portal::Offering.find_or_create_by_clazz_id_and_runnable_type_and_runnable_id(@portal_clazz.id,runnable_type,runnable_id)
      if @offering
        @offering.save
        @portal_clazz.reload
      end
      render :update do |page|
        page << "var element = $('#{dom_id}');"
        page << "element.remove();"
        page.insert_html :top, container, :partial => 'shared/offering_for_teacher', :locals => {:offering => @offering}
      end
    end
    @offering.refresh_saveable_response_objects
  end
  
  
  # HACK:
  # TODO: (IMPORTANT:) This  method is currenlty only for ajax requests, and uses dom_ids 
  # TODO: to infer runnables. Rewrite this, so that the params are less JS/DOM specific..
  def remove_offering
    @portal_clazz = Portal::Clazz.find(params[:id])
    dom_id = params[:dragged_dom_id]
    container = params[:dropped_dom_id]
    offering_id = params[:offering_id]
    @offering = Portal::Offering.find(offering_id)
    if @offering
      @runnable = @offering.runnable
      @offering.destroy
      @portal_clazz.reload
    end
    render :update do |page|
      page << "var container = $('#{container}');"
      page << "var element = $('#{dom_id}');"
      page << "element.remove();"
      page.insert_html :top, container, :partial => 'shared/runnable', :locals => {:runnable => @runnable}
    end  
  end
  
  # HACK: Add a student to a clazz
  # TODO: test this method
  # NOTE: delete student is in the student_clazzes_controller.
  # we should put these functions in the same place ...
  def add_student
    @student = nil
    @portal_clazz = Portal::Clazz.find(params[:id])

    if params[:student_id] && (!params[:student_id].empty?)
      @student = Portal::Student.find(params[:student_id])
    end
    if @student
      @student.add_clazz(@portal_clazz)
      @portal_clazz.reload
      render :update do |page|
        page.replace_html  'students_listing', :partial => 'portal/students/table_for_clazz', :locals => {:portal_clazz => @portal_clazz}
        page.visual_effect :highlight, 'students_listing'
        page.replace_html  'student_add_dropdown', @template.student_add_dropdown(@portal_clazz)
      end
    else
      render :update do |page|
        # previous message was "that was a total failure"
        # this case should not happen, but if it does, display something
        # more friendly such as:
        # page << "$('flash').update('Please elect a user from the list before clicking add button.')"
      end
    end
  end
  
  def add_teacher
    @portal_clazz = Portal::Clazz.find_by_id(params[:id])
    
    (render(:update) { |page| page << "$('flash').update('Class not found')" } and return) unless @portal_clazz
    (render(:update) { |page| page << "$('flash').update('#{Portal::Clazz::ERROR_UNAUTHORIZED}')" } and return) unless current_user && @portal_clazz.changeable?(current_user)
    
    @teacher = Portal::Teacher.find_by_id(params[:teacher_id])
    
    (render(:update) { |page| page << "$('flash').update('Teacher not found')" } and return) unless @teacher
    
    begin
      @teacher.add_clazz(@portal_clazz)
      @portal_clazz.reload
      render :update do |page|
        page.replace_html  'teachers_listing', :partial => 'portal/teachers/table_for_clazz', :locals => {:portal_clazz => @portal_clazz}
        page.visual_effect :highlight, 'teachers_listing'
      end
    rescue
      render :update do |page|
        page << "$('flash').update('There was an error while processing your request.')"
      end
    end
  end
  
  def remove_teacher
    @portal_clazz = Portal::Clazz.find_by_id(params[:id])
    (render(:update) { |page| page << "$('flash').update('Class not found')" } and return) unless @portal_clazz
    
    @teacher = @portal_clazz.teachers.find_by_id(params[:teacher_id])
    (render(:update) { |page| page << "$('flash').update('Teacher not found')" } and return) unless @teacher
    
    if (reason = @portal_clazz.reason_user_cannot_remove_teacher_from_class(current_user, @teacher))
      render(:update) { |page| page << "$('flash').update('#{reason}')" }
      return
    end

    begin
      @teacher.remove_clazz(@portal_clazz)
      @portal_clazz.reload
      
      if @teacher == current_user.portal_teacher
        flash[:notice] = "You have been successfully removed from class: #{@portal_clazz.name}"
        render(:update) { |page| page.redirect_to home_url }
      else
        # Redraw the entire table, to disable delete links as needed. -- Cantina-CMH 6/9/10
        render(:update) { |page| page.replace_html 'teachers_listing', :partial => 'portal/teachers/table_for_clazz', :locals => {:portal_clazz => @portal_clazz} }
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
    
    respond_to do |format|
      format.html { render :layout => 'report'}
    end
  end
    
end
