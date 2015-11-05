class ActivitiesController < ApplicationController
  # GET /pages
  # GET /pages.xml

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # PUNDIT_CHECK_FILTERS
  before_filter :setup_object, :except => [:index]
  before_filter :render_scope, :only => [:show]

  in_place_edit_for :activity, :name
  in_place_edit_for :activity, :description
  include ControllerParamUtils

  private

  def user_not_authorized(exception)
    case exception.query
    when :create?
      flash[:error] = "Anonymous users can not create activities"
      redirect_back_or activities_path
    when :edit?
      error_message = "you (#{current_visitor.login}) can not #{action_name.humanize} #{@activity.name}"
      flash[:error] = error_message
      if request.xhr?
        render :text => "<div class='flash_error'>#{error_message}</div>"
      else
        redirect_back_or activities_path
      end
    else
      raise exception
    end
  end

  protected

  def render_scope
    @render_scope = @activity
  end

  def setup_object
    if params[:id]
      if valid_uuid(params[:id])
        @activity = Activity.find(:first, :conditions => ['uuid=?',params[:id]])
      else
        @activity = Activity.find(params[:id])
      end
    elsif params[:activity]
      @activity = Activity.new(params[:activity])
    else
      @activity = Activity.new
    end
    format = request.parameters[:format]
    unless format == 'otml' || format == 'jnlp'
      if @activity
        @page_title = @activity.name
        @investigation = @activity.investigation
      end
    end
  end

  public

  def index
    authorize Activity
    search_params = {
      :material_types     => [Search::ActivityMaterial],
      :activity_page      => params[:page],
      :per_page           => 30,
      :user_id            => current_visitor.id,
      :grade_span         => params[:grade_span],
      :private            => current_visitor.has_role?('admin'),
      :search_term        => params[:search]
    }

    s = Search.new(search_params)
    @activities = s.results[Search::ActivityMaterial]
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (found instance)
    # @activities = policy_scope(Activity)

    if params[:mine_only]
      @activities = @activities.reject { |i| i.user.id != current_visitor.id }
    end

    if request.xhr?
      render :partial => 'activities/runnable_list', :locals => {:activities => @activities, :paginated_objects =>@activities}
    else
      respond_to do |format|
        format.html do
          render 'index'
        end
        format.js
      end
    end
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    authorize @activity
    @teacher_mode = boolean_param(:teacher_mode) || @activity.teacher_only
    respond_to do |format|
      format.html {
        if params['print']
          render :print, :layout => "layouts/print"
        end
      }
      format.run_html   { render :show, :layout => "layouts/run" }
      format.jnlp   {
        render :partial => 'shared/installer', :locals => { :runnable => @activity, :teacher_mode => @teacher_mode }
      }
      format.config { render :partial => 'shared/show', :locals => { :runnable => @activity, :teacher_mode => @teacher_mode, :session_id => (params[:session] || request.env["rack.session.options"][:id]) } }
      format.dynamic_otml {
        learner = (params[:learner_id] ? Portal::Learner.find(params[:learner_id]) : nil)
        if learner && learner.bundle_logger.in_progress_bundle
          launch_event = Dataservice::LaunchProcessEvent.create(
            :event_type => Dataservice::LaunchProcessEvent::TYPES[:activity_otml_requested],
            :event_details => "Activity content loaded. Activity should now be running...",
            :bundle_content => learner.bundle_logger.in_progress_bundle
          )
        end
        render :partial => 'shared/show', :locals => {:runnable => @activity, :teacher_mode => @teacher_mode}
      }
      format.otml { render :layout => 'layouts/activity' } # activity.otml.haml
      format.xml  { render :xml => @activity }
      format.pdf {render :layout => false }
    end
  end

  # GET /pages/new
  # GET /pages/new.xml
  def new
    authorize Activity

    @activity = Activity.new
    @activity.user = current_visitor
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @activity }
    end
  end

  # GET /pages/1/edit
  def edit
    @activity = Activity.find(params[:id])
    authorize @activity
    if request.xhr?
      render :partial => 'remote_form', :locals => { :activity => @activity }
    end
  end

  # POST /pages
  # POST /pages.xml
  def create
    authorize Activity

    @activity = Activity.new(params[:activity])
    @activity.user = current_visitor

    if params[:update_cohorts]
      # set the cohort tags
      @activity.cohort_list = (params[:cohorts] || [])
    end

    if params[:update_grade_levels]
      # set the grade_level tags
      @activity.grade_level_list = (params[:grade_levels] || [])
    end

    if params[:update_subject_areas]
      # set the subject_area tags
      @activity.subject_area_list = (params[:subject_areas] || [])
    end

    respond_to do |format|
      if @activity.save
        format.js  # render the js file
        flash[:notice] = 'Activity was successfully created.'
        format.html { redirect_to(@activity) }
        format.xml  { render :xml => @activity, :status => :created, :location => @activity }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @activity = Activity.find(params[:id])
    authorize @activity

    if params[:update_cohorts]
      # set the cohort tags
      @activity.cohort_list = (params[:cohorts] || [])
      @activity.save
    end

    if params[:update_grade_levels]
      # set the grade_level tags
      @activity.grade_level_list = (params[:grade_levels] || [])
      @activity.save
    end

    if params[:update_subject_areas]
      # set the subject_area tags
      @activity.subject_area_list = (params[:subject_areas] || [])
      @activity.save
    end

    if request.xhr?
      if cancel || @activity.update_attributes(params[:activity])
        render :partial => 'shared/activity_header', :locals => { :activity => @activity }
      else
        render :xml => @activity.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @activity.update_attributes(params[:activity])
          flash[:notice] = 'Activity was successfully updated.'
          format.html { redirect_to(@activity) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
        end
      end
    end
  end


  # DELETE /pages/1
  # DELETE /pages/1.xml
  def destroy
    @activity = Activity.find(params[:id])
    authorize @activity
    @activity.destroy
    @redirect = params[:redirect]
    respond_to do |format|
      format.html { redirect_back_or(activities_url) }
      format.js
      format.xml  { head :ok }
    end
  end


  ##
  ##
  ##
  def add_section
    authorize Section, :create?
    @section = Section.create
    @section.activity = @activity
    @section.user = current_visitor
    @section.save
    redirect_to @section
  end

  ##
  ##
  ##
  def sort_sections
    paramlistname = params[:list_name].nil? ? 'activity_sections_list' : params[:list_name]
    @activity = Activity.find(params[:id], :include => :sections)
    authorize @activity, :update_edit_or_destroy?
    @activity.sections.each do |section|
      section.position = params[paramlistname].index(section.id.to_s) + 1
      section.save
    end
    render :nothing => true
  end

  ##
  ##
  ##
  def delete_section
    @section= Section.find(params['section_id'])
    authorize @section, :destroy?
    @section.destroy
  end

  ##
  ##
  ##
  def duplicate

    @original = Activity.find(params['id'])
    # PUNDIT_REVIEW_AUTHORIZE
    authorize @original, :show?
    authorize Activity, :create?
    @activity = @original.deep_clone :no_duplicates => true, :never_clone => [:uuid, :created_at, :updated_at], :include => {:sections => :pages}
    @activity.name = "copy of #{@activity.name}"
    @activity.deep_set_user current_visitor
    @activity.save
    flash[:notice] ="Copied #{@original.name}"
    redirect_to url_for(@activity)
  end

  #
  # Construct a link suitable for a 'paste' action in this controller.
  #
  def paste_link
    # no authorization needed ...
    render :partial => 'shared/paste_link', :locals =>{:types => ['section'],:params => params}
  end

  #
  # In an Activities controller, we only accept section clipboard data,
  #
  def paste
    # PUNDIT_REVIEW_AUTHORIZE
    authorize @activity, :edit
    if @activity.changeable?(current_visitor)
      @original = clipboard_object(params)
      if (@original)
        @component = @original.deep_clone :no_duplicates => true, :never_clone => [:uuid, :updated_at,:created_at], :include => :pages
        if (@component)
          # @component.original = @original
          @container = params[:container] || 'activity_sections_list'
          @component.name = "copy of #{@component.name}"
          @component.deep_set_user current_visitor
          @component.activity = @activity
          @component.save
        end
      end
    end
    render :update do |page|
      page.insert_html :bottom, @container, render(:partial => 'section_list_item', :locals => {:section => @component})
      page.sortable :activity_sections_list, :handle=> 'sort-handle', :dropOnEmpty => true, :url=> {:action => 'sort_sections', :params => {:activity_id => @activity.id }}
      page[dom_id_for(@component, :item)].scrollTo()
      page.visual_effect :highlight, dom_id_for(@component, :item)
    end
  end

  def export
    authorize @activity, :show?
    respond_to do |format|
      format.xml  {
        send_data @activity.deep_xml, :type => :xml, :filename=>"#{@activity.name}.xml"
      }
    end
  end

end
