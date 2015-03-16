class ExternalActivitiesController < ApplicationController
  include PeerAccess

  before_filter :setup_object, :except => [:index, :preview_index, :publish]
  before_filter :render_scope, :only => [:show]
  # editing / modifying / deleting require editable-ness
  before_filter :can_edit, :except => [:index,:show,:print,:create,:new,:duplicate,:export,:publish,:republish,:copy,:matedit]
  before_filter :can_create, :only => [:new, :create, :duplicate, :publish]
  before_filter :only_peers, :only => [:republish]
  in_place_edit_for :external_activity, :name
  in_place_edit_for :external_activity, :description
  in_place_edit_for :external_activity, :url

  def only_peers
    if verify_request_is_peer
      return true
    else
      json_error('missing or invalid peer token', 401)
    end
  end

  def json_error(msg,code=422)
    render :json => { :error => msg }, :content_type => 'text/json', :status => code
  end

  def can_create
    if (current_visitor.anonymous?)
      logger.warn "Didn't proceed: current_visitor.anonymous? was true"
      logger.info "Current visitor: #{current_visitor.to_s}"
      flash[:error] = "Anonymous users can not create external external_activities"
      redirect_back_or external_activities_path
    end
  end

  def render_scope
    @render_scope = @external_activity
  end

  def can_edit
    if defined? @external_activity
      unless @external_activity.changeable?(current_visitor)
        error_message = "you (#{current_visitor.login}) can not #{action_name.humanize} #{@external_activity.name}"
        flash[:error] = error_message
        if request.xhr?
          render :text => "<div class='flash_error'>#{error_message}</div>"
        else
          redirect_back_or external_activities_path
        end
      end
    end
  end


  def setup_object
    if params[:id]
      if valid_uuid(params[:id])
        @external_activity = ExternalActivity.find(:first, :conditions => ['uuid=?',params[:id]])
      else
        @external_activity = ExternalActivity.find(params[:id])
      end
    elsif params[:external_activity]
      @external_activity = ExternalActivity.new(params[:external_activity])
    else
      @external_activity = ExternalActivity.new
    end
    @page_title = @external_activity.name if @external_activity
  end

  public

  def index
    search_params = { :material_types => [ExternalActivity], :page => params[:page] }
    if !params[:name].blank?
      search_params[:search_term] = params[:name]
    end
    if !current_visitor.has_role?('admin')
      search_params[:private] = true
      search_params[:user_id] = current_visitor.id
    end
    s = Search.new(search_params)
    @external_activities = s.results[:all]

    if request.xhr?
      render :partial => 'external_activities/runnable_list', :locals => {:external_activities => @external_activities, :paginated_objects => @external_activities}
    else
      respond_to do |format|
        format.html do
          render 'index'
        end
        format.js
      end
    end
  end

  def preview_index
    page= params[:page] || 1
    @activities = ExternalActivity.all.paginate(
        :page => page || 1,
        :per_page => params[:per_page] || 20,
        :order => 'name')
    render 'preview_index'
  end

  # GET /external_activities/1
  # GET /external_activities/1.xml
  def show
    # @teacher_mode = params[:teacher_mode] || @external_activity.teacher_only
    respond_to do |format|
      format.html {
        if params['print']
          render :print, :layout => "layouts/print"
        end
      }
      format.run_resource_html   { redirect_to(@external_activity.url) }
      format.xml  { render :xml => @external_activity }
    end
  end

  # GET /external_activities/new
  # GET /external_activities/new.xml
  def new
    @external_activity = ExternalActivity.new
    @external_activity.user = current_visitor
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @external_activity }
    end
  end

  # GET /external_activities/1/edit
  def edit
    @external_activity = ExternalActivity.find(params[:id])
    if request.xhr?
      render :partial => 'form'
    end
  end

  # POST /pages
  # POST /pages.xml
  def create
    @external_activity = ExternalActivity.new(params[:external_activity])
    @external_activity.user = current_visitor

    if params[:update_cohorts]
      # set the cohort tags
      @external_activity.cohort_list = (params[:cohorts] || [])
    end

    if params[:update_grade_levels]
      # set the grade_level tags
      @external_activity.grade_level_list = (params[:grade_levels] || [])     
    end

    if params[:update_subject_areas]
      # set the subject_area tags
      @external_activity.subject_area_list = (params[:subject_areas] || [])
    end

    respond_to do |format|
      if @external_activity.save
        format.js  # render the js file
        flash[:notice] = 'ExternalActivity was successfully created.'
        format.html { redirect_to(@external_activity) }
        format.xml  { render :xml => @external_activity, :status => :created, :location => @external_activity }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @external_activity.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /external_activities/1
  # PUT /external_activities/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @external_activity = ExternalActivity.find(params[:id])

    if params[:update_cohorts]
      # set the cohort tags
      @external_activity.cohort_list = (params[:cohorts] || [])
      @external_activity.save
    end

    if params[:update_grade_levels]
      # set the grade_level tags
      @external_activity.grade_level_list = (params[:grade_levels] || [])
      @external_activity.save
    end

    if params[:update_subject_areas]
      # set the subject_area tags
      @external_activity.subject_area_list = (params[:subject_areas] || [])
      @external_activity.save
    end

    if request.xhr?
      if cancel || @external_activity.update_attributes(params[:external_activity])
        render :partial => 'shared/external_activity_header', :locals => { :external_activity => @external_activity }
      else
        render :xml => @external_activity.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @external_activity.update_attributes(params[:external_activity])
          flash[:notice] = 'ExternalActivity was successfully updated.'
          format.html { redirect_to(@external_activity) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @external_activity.errors, :status => :unprocessable_entity }
        end
      end
    end
  end


  # DELETE /external_activities/1
  # DELETE /external_activities/1.xml
  def destroy
    @external_activity = ExternalActivity.find(params[:id])
    @external_activity.destroy
    @redirect = params[:redirect]
    respond_to do |format|
      format.html { redirect_back_or(external_activities_url) }
      format.js
      format.xml  { head :ok }
    end
  end

  def publish
    json = JSON.parse(request.body.read)
    begin
      if params[:version].present? and params[:version] == 'v2'
        @external_activity = ActivityRuntimeAPI.publish2(json, current_visitor)
      else
        @external_activity = ActivityRuntimeAPI.publish(json, current_visitor)
      end
      head :created, :location => @external_activity
    rescue StandardError => e
      json_error(e)
    end
  end

  # If we have an authentication token from the authoring client
  # then we can republish without concern for current user.
  def republish
    json = JSON.parse(request.body.read)
    begin
      @external_activity = ActivityRuntimeAPI.republish(json)
      head :created, :location => @external_activity
    rescue StandardError => e
      json_error(e)
    end
  end

  ##
  ##
  ##
  def duplicate
    @original = ExternalActivity.find(params['id'])
    @external_activity = @original.deep_clone :no_duplicates => true, :never_clone => [:uuid, :created_at, :updated_at], :include => [{:teacher_notes => {}}, {:author_notes => {}}]
    @external_activity.name = "copy of #{@external_activity.name}"
    @external_activity.user = current_visitor
    @external_activity.save

    (@external_activity.teacher_notes + @external_activity.author_notes).each {|tn| n.user = current_visitor; n.save }

    flash[:notice] ="Copied #{@original.name}"
    redirect_to url_for(@external_activity)
  end
  
  def matedit
    @uri = URI.parse(@external_activity.url + '/edit')
    @uri.query = {
      :domain => root_url,
      :domain_uid => current_visitor.id
    }.to_query
    if params[:iFrame] == "false"
      redirect_to @uri.to_s
    end
  end
  
  def copy
    @uri = URI.parse(@external_activity.url + '/duplicate')
    @uri.query = {
      :domain => root_url,
      :domain_uid => current_visitor.id
    }.to_query
    redirect_to @uri.to_s
  end

end
