class InvestigationsController < AuthoringController
  
  # This doesn't work, but the technique is described here:
  # vendor/rails/actionpack/lib/action_controller/caching/pages.rb:91
  # caches_page :show if => Proc.new { |c| c.request.format == :otml }

  # caches_action :show
  # cache_sweeper :investigation_sweeper, :only => [ :update ]

  prawnto :prawn=>{ :page_layout=>:landscape }

  before_filter :setup_object, :except => [:index,:list_filter]
  before_filter :render_scope, :only => [:show]
  # editing / modifying / deleting require editable-ness
  before_filter :can_edit, :except => [:list_filter, :index,:show,:teacher,:print,:create,:new,:duplicate,:export, :gse_select]
  before_filter :can_create, :only => [:new, :create, :duplicate]
  
  in_place_edit_for :investigation, :name
  in_place_edit_for :investigation, :description
  
  after_filter :cache_otml

  protected  

  def cache_otml
    if request.format == :otml
      cache_page(response.body, request.path)
    end
  end

  def can_create
    if (current_user.anonymous?)
      flash[:error] = "Anonymous users can not create investigaitons"
      redirect_back_or investigations_path
    end
  end
  
  def render_scope
    @render_scope = @investigation
  end
  
  def can_edit
    if defined? @investigation
      unless @investigation.changeable?(current_user)
        error_message = "you (#{current_user.login}) can not #{action_name.humanize} #{@investigation.name}"
        flash[:error] = error_message
        if request.xhr?
          render :text => "<div class='flash_error'>#{error_message}</div>"
        else
          redirect_back_or investigations_path
        end
      end
    end
  end
  
  def setup_object
    if params[:id]
      if params[:id].length == 36
        @investigation = Investigation.find(:first, :conditions => ['uuid=?',params[:id]])
      else
        @investigation = Investigation.find(params[:id])
      end
    elsif params[:investigation]
      @investigation = Investigation.new(params[:investigation])
    else
      @investigation = Investigation.new
    end
    @page_title = @investigation.name
    format = request.parameters[:format]
    unless format == 'otml' || format == 'jnlp'
      if @investigation
      end
    end
  end
  
  def param_find(token_sym, force_nil=false)
    token = token_sym.to_s
     eval_string = <<-EOF
      if params[:#{token}]
        session[:#{token}] = cookies[:#{token}]= #{token} = params[:#{token}]
      elsif force_nil
         session[:#{token}] = cookies[:#{token}] = nil
      else
        #{token} = session[:#{token}] || cookies[:#{token}]
      end
    EOF
    eval eval_string
  end
  
  public

  # POST /grade_span_expectations/select_js
  def index
    @grade_span = param_find(:grade_span)
    @domain_id = param_find(:domain_id)
    @include_drafts = params[:include_drafts]
    @name = param_find(:name)
    pagenation = params[:page]
    if (pagenation)
      @include_drafts = param_find(:include_drafts)
    else
      @include_drafts = param_find(:include_drafts,true)
    end
    @investigations = Investigation.search_list({
      :ignore_gse => true,
      :name => @name, 
      :portal_clazz_id => @portal_clazz_id, 
      :include_drafts => @include_drafts, 
      :paginate => true, 
      :page => pagenation
    })
    if params[:mine_only]
      @investigations = @investigations.reject { |i| i.user.id != current_user.id }
    end
    @paginated_objects = @investigations
    
    if request.xhr?
      render :partial => 'investigations/runnable_list', :locals => {:investigations => @investigations, :paginated_objects =>@investigations}
    else
      respond_to do |format|
        format.js
        format.html do
          render 'index'
        end
      end
    end
  end



  # GET /pages/1
  # GET /pages/1.xml
  def show
    # display for teachers? Later we can determin via roles?    
    @teacher_mode = params[:teacher_mode]
    respond_to do |format|
      format.html {
        if params['print'] 
          render :print, :layout => "layouts/print"
        end
      }
      format.jnlp   { render :partial => 'shared/show', :locals => { :runnable => @investigation, :teacher_mode => @teacher_mode } }
      format.config { render :partial => 'shared/show', :locals => { :runnable => @investigation, :teacher_mode => @teacher_mode, :session_id => (params[:session] || request.env["rack.session.options"][:id]) } }
      format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @investigation, :teacher_mode => @teacher_mode} }
      format.otml   { render :layout => 'layouts/investigation' } # investigation.otml.haml
      format.xml    { render :xml => @investigation }
      format.pdf    { render :layout => false }
    end
  end


  # GET /investigations/1.otml/teacher_otml
  # GET /pages/1.xml
  def teacher
    # display for teachers? Later we can determin via roles?
    @teacher_mode = true
    render :layout => 'layouts/investigation', :action => :show
  end

  # GET /pages/new
  # GET /pages/new.xml
  def new
    @investigation = Investigation.new
    @investigation.user = current_user
    @gse = GradeSpanExpectation.find_by_grade_span('9-11')
    @investigation.grade_span_expectation = @gse
    session[:original_gse_id] = session[:gse_id] = @gse.id
    session[:original_grade_span] = session[:grade_span] = grade_span = @gse.grade_span
    session[:original_domain_id] = session[:domain_id] = @gse.domain.id
    domain = Domain.find(@gse.domain.id)
    gses = domain.grade_span_expectations 
    @related_gses = gses.find_all { |gse| gse.grade_span == grade_span }
    if request.xhr?
      render :partial => 'remote_form', :locals => { :investigation => @investigation, :related_gses => @related_gses, :selected_gse =>@gse}
    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @investigation }
    end
  end

  # GET /pages/1/edit
  def edit
    @investigation = Investigation.find(params[:id])
    # if there is no gse assign a default one:
    unless @gse = @investigation.grade_span_expectation
      @gse = GradeSpanExpectation.find_by_grade_span('9-11')
      @investigation.grade_span_expectation = @gse
      @investigation.save!
    end
    
    session[:original_gse_id] = session[:gse_id] = @gse.id
    session[:original_grade_span] = session[:grade_span] = grade_span = @gse.grade_span
    session[:original_domain_id] = session[:domain_id] = @gse.domain.id
    domain = Domain.find(@gse.domain.id)
    gses = domain.grade_span_expectations 
    @related_gses = gses.find_all { |gse| gse.grade_span == grade_span }
    if request.xhr?
      render :partial => 'remote_form', :locals => { :investigation => @investigation,:related_gses => @related_gses, :selected_gse => @gse}
    end
  end

  # POST /pages
  # POST /pages.xml
  def create
    begin
      gse = GradeSpanExpectation.find(params[:grade_span_expectation])
      params[:investigation][:grade_span_expectation] = gse
    rescue
      logger.error('could not find gse')
    end
    @investigation = Investigation.new(params[:investigation])
    @investigation.user = current_user
    respond_to do |format|
      if @investigation.save
        flash[:notice] = 'Investigation was successfully created.'
        format.html { redirect_to(@investigation) }
        format.xml  { render :xml => @investigation, :status => :created, :location => @investigation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @investigation.errors, :status => :unprocessable_entity }
      end
    end
  end

  def gse_select
    if params[:grade_span_expectation]
      @selected_gse = GradeSpanExpectation.find_by_id(params[:grade_span_expectation][:id])
      session[:gse_id] = @selected_gse.id
    else
      @selected_gse = GradeSpanExpectation.find_by_id(session[:gse_id])
    end
    # remember the chosen domain and grade_span, it will probably continue.
    if grade_span = params[:grade_span]
      session[:grade_span] = grade_span
      domain_id = session[:domain_id]
    elsif params[:domain_id]
      domain_id = params[:domain_id].to_i
      session[:domain_id] = domain_id
      grade_span = session[:grade_span]
    else
      grade_span = session[:grade_span]
      domain_id = session[:domain_id]
    end
    # FIXME 
    # domains (as an associated model) are way too far away from a gse
    # I added some finder_sql to the domain model to make this faster
    domain = Domain.find(domain_id)
    gses = domain.grade_span_expectations 
    @related_gses = gses.find_all { |gse| gse.grade_span == grade_span }
    if request.xhr?
      render :partial => 'gse_select', :locals => { :related_gses => @related_gses, :selected_gse => @selected_gse }
    else
      respond_to do |format|
        format.js { render :partial => 'gse_select', :locals => { :related_gses => @related_gses, :selected_gse => @selected_gse } }
      end
    end
  end
  
  
  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    @investigation = Investigation.find(params[:id])

    if request.xhr?
      if cancel || @investigation.update_attributes(params[:investigation])
        render :partial => 'shared/investigation_header', :locals => { :investigation => @investigation }
      else
        render :xml => @investigation.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @investigation.update_attributes(params[:investigation])
          flash[:notice] = 'Investigation was successfully updated.'
          format.html { redirect_to(@investigation) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @investigation.errors, :status => :unprocessable_entity }
        end
      end
    end
  end
  
  # DELETE /pages/1
  # DELETE /pages/1.xml
  def destroy
    @investigation = Investigation.find(params[:id])
    @investigation.destroy

    respond_to do |format|
      format.html { redirect_back_or(activities_url) }
      format.js
      format.xml  { head :ok }
    end
  end
  
  ##
  ##
  ##
  def add_activity
    @activity = Activity.new
    @activity.user = current_user
    @activity.investigation = Investigation.find(params['id'])
  end
  
  ##
  ##
  ##  
  def sort_activities
    paramlistname = params[:list_name].nil? ? 'investigation_activities_list' : params[:list_name]    
    @investigation = Investigation.find(params[:id], :include => :activities)
    @investigation.activities.each do |section|
      section.position = params[paramlistname].index(section.id.to_s) + 1
      section.save
    end 
    render :nothing => true
  end

  ##
  ##
  ##
  def delete_activity
    @activity= Activity.find(params['activity_id'])
    # @activity.update_investigation_timestamp
    @activity.destroy
  end  
  
  ##
  ##
  ##
  def duplicate
    @original = Investigation.find(params['id'])
    @investigation = @original.duplicate(current_user)
    @investigation.save
    
    redirect_to edit_investigation_url(@investigation)
  end
  
  def export
    respond_to do |format|
      format.xml  { 
        send_data @investigation.deep_xml, :type => :xml, :filename=>"#{@investigation.name}.xml"
      }
    end
  end
  

  #
  # Construct a link suitable for a 'paste' action in this controller.
  #
  def paste_link
    render :partial => 'shared/paste_link', :locals =>{:types => ['activity'],:parmas => params}
  end
  
  #
  # In an Investigation controller, we only accept activity clipboard data,
  # see: views/investigations/_paste_link
  # 
  def paste
    if @investigation.changeable?(current_user)
      clipboard_data_type = params[:clipboard_data_type] || cookies[:clipboard_data_type]
      clipboard_data_id = params[:clipboard_data_id] || cookies[:clipboard_data_id]
      klass = clipboard_data_type.pluralize.classify.constantize
      @original = klass.find(clipboard_data_id)
      if (@original) 
        @component = @original.deep_clone :no_duplicates => true, :never_clone => [:uuid, :updated_at,:created_at], :include => {:sections => {:pages => {:page_elements => :embeddable}}}
        if (@component)
          # @component.original = @original
          @container = params[:container] || 'investigation_activities_list'
          @component.name = "copy of #{@component.name}"
          @component.deep_set_user current_user
          @component.investigation = @investigation
          @component.save
        end
      end
    end

    render :update do |page|
      page.insert_html :bottom, @container, render(:partial => 'activity_list_item', :locals => {:activity => @component})
      page.sortable :investigation_activities_list, :handle=> 'sort-handle', :dropOnEmpty => true, :url=> {:action => 'sort_activities', :params => {:investigation_id => @investigation.id }}
      page[dom_id_for(@component, :item)].scrollTo()
      page.visual_effect :highlight, dom_id_for(@component, :item)
    end
  end
  
end