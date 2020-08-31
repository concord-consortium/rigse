class ExternalActivitiesController < ApplicationController

  private

  def pundit_user_not_authorized(exception)
    case exception.query.to_s
    when 'republish?'
      json_error('missing or invalid peer token', 401)
    else
      logger.warn "Didn't proceed: current_visitor.anonymous? was true" if current_visitor.anonymous?
      logger.info "Current visitor: #{current_visitor.to_s}"
      super(exception)
    end
  end

  protected

  def humanized_action
    super({
      matedit: "edit",
      edit_basic: "edit",
      set_private_before_matedit: "set_private_before_edit"
    })
  end

  def not_authorized_error_message
    super({resource_type: 'external activity', resource_name: @external_activity ? @external_activity.name : nil})
  end

  public

  before_filter :setup_object, :except => [:index, :preview_index, :publish]
  before_filter :render_scope, :only => [:show]
  in_place_edit_for :external_activity, :name
  in_place_edit_for :external_activity, :description
  in_place_edit_for :external_activity, :url

  def index
    authorize ExternalActivity
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
    authorize @external_activity
    respond_to do |format|
      format.html {
        redirect_to(browse_external_activity_path(@external_activity))
      }
      format.run_resource_html {
        # ensure that a logged in user is the same user on LARA
        if !current_visitor.anonymous?
           uri = URI.parse(@external_activity.url)
           query = Rack::Utils.parse_query(uri.query)
           query["domain"] = root_url
           query["domain_uid"] = current_visitor.id
           uri.query = Rack::Utils.build_query(query)
           redirect_to(uri.to_s)
        else
          redirect_to(@external_activity.url)
        end
      }
      format.xml  { render xml: @external_activity }
      format.json { render json: @external_activity }
    end
  end

  # GET /external_activities/new
  # GET /external_activities/new.xml
  def new
    authorize ExternalActivity
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
    authorize @external_activity
    if request.xhr?
      render :partial => 'form'
    end
  end

  # subset of editing provided to owners of the activities
  def edit_basic
    @external_activity = ExternalActivity.find(params[:id])
    authorize @external_activity
    if request.xhr?
      render :partial => 'basic_form'
    end
  end

  # POST /pages
  # POST /pages.xml
  def create
    authorize ExternalActivity
    @external_activity = ExternalActivity.new(params[:external_activity])
    @external_activity.user = current_visitor

    if params[:update_material_properties]
      # set the material_properties tags
      @external_activity.material_property_list = (params[:material_properties] || [])
    end

    if params[:update_cohorts]
      # set the cohorts
      @external_activity.set_cohorts_by_id(params[:cohort_ids] || [])
    end

    if params[:update_grade_levels]
      # set the grade_level tags
      @external_activity.grade_level_list = (params[:grade_levels] || [])
    end

    if params[:update_subject_areas]
      # set the subject_area tags
      @external_activity.subject_area_list = (params[:subject_areas] || [])
    end

    if params[:update_sensors]
      # set the sensor tags
      @external_activity.sensor_list = (params[:sensors] || [])
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
    authorize @external_activity

    if params[:update_material_properties]
      # set the material_properties tags
      @external_activity.material_property_list = (params[:material_properties] || [])
      @external_activity.save
    end

    if params[:update_cohorts]
      # set the cohort tags
      @external_activity.set_cohorts_by_id(params[:cohort_ids] || [])
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

    if params[:update_sensors]
      # set the sensor tags
      @external_activity.sensor_list = (params[:sensors] || [])
      @external_activity.save
    end

    if params[:update_external_reports]
      # set the external reports
      @external_activity.external_report_ids= (params[:external_reports] || [])
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
          # redirect to browse path instead of show page since the show page is deprecated
          format.html { redirect_to(browse_external_activity_path(@external_activity)) }
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
    authorize @external_activity
    @external_activity.destroy
    @redirect = params[:redirect]
    respond_to do |format|
      format.html { redirect_back_or(external_activities_url) }
      format.js
      format.xml  { head :ok }
    end
  end

  def publish
    authorize ExternalActivity
    json = JSON.parse(request.body.read)
    begin
      if params[:version].present? and params[:version] == 'v2'
        @external_activity = ActivityRuntimeAPI.publish2(json, current_visitor)
      else
        @external_activity = ActivityRuntimeAPI.publish(json, current_visitor)
      end
      head :created, :location => @external_activity
      response.body = {:activity_id => @external_activity.id}.to_json
    rescue StandardError => e
      json_error(e.inspect)
    end
  end

  # If we have an authentication token from the authoring client
  # then we can republish without concern for current user.
  def republish
    authorize ExternalActivity
    json = JSON.parse(request.body.read)
    begin
      @external_activity = ActivityRuntimeAPI.republish(json)
      head :created, :location => @external_activity
      response.body = {:activity_id => @external_activity.id}.to_json
    rescue StandardError => e
      json_error(e.inspect)
    end
  end

  def matedit
    authorize @external_activity
    @uri = ssl_if_we_are(URI.parse("#{@external_activity.url}/edit"))
    @uri.query = {
      :domain => root_url,
      :domain_uid => current_visitor.id
    }.to_query
    if params[:iFrame] == "false"
      redirect_to @uri.to_s
    end
  end

  def archive
    authorize @external_activity
    @external_activity.archive!
    flash[:notice]= t("matedit.archive_success", {name: @external_activity.name})
    redirect_to :search  #TBD:  Where to go?
  end

  def unarchive
    authorize @external_activity
    @external_activity.unarchive!
    flash[:notice]= t("matedit.unarchive_success", {name: @external_activity.name})
    redirect_to :search  #TBD:  Where to go?
  end

  def set_private_before_matedit
    authorize ExternalActivity
    @external_activity.publication_status = 'private'
    @external_activity.save
    redirect_uri = URI.parse(matedit_external_activity_url(@external_activity.id))
    redirect_uri.query = {
      :iFrame => params[:iFrame]
    }.to_query
    redirect_to redirect_uri.to_s
  end

  def copy
    authorize ExternalActivity
    clone = @external_activity.duplicate(current_visitor, root_url)
    if clone
      redirect_to matedit_external_activity_url(clone.id)
    else
      flash[:error] = "Copying failed"
      redirect_to :back
    end
  end

  def edit_collections
    authorize @external_activity

    @collections = MaterialsCollection.includes(:materials_collection_items).order(:name).all

    @material = [@external_activity]
    @assigned_collections = @collections.select{|c| _collection_has_materials(c, @material) }

    @unassigned_collections = @collections - @assigned_collections

    respond_to do |format|
      format.html # edit_collections.html.haml
    end
  end

  def update_collections
    authorize @external_activity

    @external_activity = ExternalActivity.find(params[:material_id])
    collection_ids = params[:materials_collection_id] || []

    if external_activity_type != "ExternalActivity"
      raise 'unsupported type or length'
    end

    if collection_ids.count > 0
      add_material_to_collection(collection_ids, @external_activity)
      flash[:notice] = "#{@external_activity.name} is assigned to the selected collection(s) successfully."
    else
      flash[:error] = "Select at least one collection to assign this #{@external_activity.material_type.classify}"
    end

    redirect_to action: 'edit_collections', material_id: @external_activity.id, material_type: @external_activity.material_type
  end

  private

  def add_material_to_collection(collection_ids, material)
    collection_ids.each do |collection_id|
      collection = MaterialsCollection.includes(:materials_collection_items).find(collection_id)
      collection_items = collection.materials_collection_items
      item = collection_items.find_by_material_id_and_material_type(material.id, material.material_type)
      if item.nil?
        item = MaterialsCollectionItem
                   .where(materials_collection_id: collection.id,
                          material_type: material.material_type,
                          material_id: material.id)
                   .first_or_create
      end
      if item.position.nil?
        item.position = collection_items.length
        item.save!
      end
    end
  end

  def _collection_has_materials(collection, materials)
    items = collection.materials_collection_items.map{|i| [i.material_type, i.material_id] }
    material_items = materials.map {|m| [m.class.to_s, m.id] }

    has_them_all = (material_items - items).empty? && (material_items & items).length == material_items.length
    return has_them_all
  end

  def json_error(msg,code=422)
    render :json => { :error => msg }, :content_type => 'text/json', :status => code
  end

  def render_scope
    @render_scope = @external_activity
  end

  def setup_object
    if params[:id]
      if valid_uuid(params[:id])
        @external_activity = ExternalActivity.where('uuid=?',params[:id]).first
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

  def ssl_if_we_are(input_uri)
    # return a copy of input_uri that is https if our request was https
    # dont change otherwise.
    return_uri = input_uri.dup
    we_are_ssl = URI.parse(request.url).scheme =~ /https/i
    return_uri.scheme="https" if we_are_ssl
    return_uri
  end

end
