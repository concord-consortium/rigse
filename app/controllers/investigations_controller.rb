class InvestigationsController < AuthoringController
  # This doesn't work, but the technique is described here:
  # vendor/rails/actionpack/lib/action_controller/caching/pages.rb:91
  # caches_page :show if => Proc.new { |c| c.request.format == :otml }

  # caches_action :show
  # cache_sweeper :investigation_sweeper, :only => [ :update ]

  include RestrictedController
  #access_rule 'researcher', :only => [:usage_report, :details_report]
  prawnto :prawn=>{ :page_layout=>:landscape }

  before_filter :setup_object, :except => [:index,:list_filter,:preview_index]
  before_filter :render_scope, :only => [:show]
  # editing / modifying / deleting require editable-ness
  before_filter :manager_or_researcher, :only => [:usage_report, :details_report]
  before_filter :can_edit, :except => [:usage_report, :details_report, :preview_index, :list_filter, :index,:show,:teacher,:print,:printable_index,:create,:new,:duplicate,:export, :gse_select]
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


  def update_gse
    if params[:grade_span_expectation_id] && params[:investigation]
      params[:investigation][:grade_span_expectation_id] = params[:grade_span_expectation_id]
    end
  end

  public

  # POST /investigations/select_js
  def index
    # @grade_span = param_find(:grade_span)
    # @domain_id = param_find(:domain_id)
    # @name = param_find(:name
    # don't save these, see: http://www.pivotaltracker.com/story/show/2428013
    @grade_span = params[:grade_span]
    @domain_id = params[:domain_id]
    @include_drafts = param_find(:include_drafts)
    @name = param_find(:name)
    pagination = params[:page] == "" ? 1 : params[:page]
    if (params[:method] == :get)
      @include_drafts = param_find(:include_drafts,true)
      pagination = params[:page] = 1
    else
      @include_drafts = param_find(:include_drafts)
    end

    @sort_order = param_find(:sort_order, true)
    if params[:include_usage_count].blank?
      # The checkbox was unchecked. No other way to detect this as the param gets passed as nil
      # unless it was actually checked as part of the request
      session[:include_usage_count] = false if params[:method] == :get
    else
      session[:include_usage_count] = params[:include_usage_count]
    end

    search_options = {
      :name => @name,
      :portal_clazz_id => @portal_clazz_id,
      :include_drafts => @include_drafts,
      :grade_span => @grade_span,
      :domain_id => @domain_id,
      :sort_order => @sort_order,
      :paginate => true,
      :page => pagination
    }
    @investigations = Investigation.search_list(search_options)

    if params[:mine_only]
      @investigations = @investigations.reject { |i| i.user.id != current_user.id }
    end

    @paginated_objects = @investigations

    if request.xhr?
      @resource_pages = ResourcePage.search_list(search_options) unless params[:investigations_only]
      render :partial => 'investigations/runnable_list_with_resource_pages', :locals => {
        :investigations => @investigations,
        :resource_pages => @resource_pages
      }
    else
      respond_to do |format|
        format.html do
          render 'index'
        end
        format.js
      end
    end
  end

  def printable_index
    @investigations = Investigation.search_list({
      :name => param_find(:name),
      :portal_clazz_id => @portal_clazz_id,
      :include_drafts => param_find(:include_drafts, true),
      :grade_span => param_find(:grade_span),
      :domain_id => param_find(:domain_id),
      :sort_order => param_find(:sort_order),
      :paginate => false
    })

    if params[:mine_only]
      @investigations = @investigations.reject { |i| i.user.id != current_user.id }
    end

    render :layout => false
  end

  def preview_index
    page= params[:page] || 1
    @investigations = Investigation.published.paginate(
        :page => page || 1,
        :per_page => params[:per_page] || 20,
        :order => 'name')
    render 'preview_index'
  end

  # GET /investigations/1
  # GET /investigations/1.jnlp
  # GET /investigations/1.config
  # GET /investigations/1.dynamic_otml
  # GET /investigations/1.otml
  def show
    # display for teachers? Later we can determin via roles?
    @teacher_mode = params[:teacher_mode]
    respond_to do |format|
      format.html {
        if params['print']
          render :print, :layout => "layouts/print"
        end
      }

      format.jnlp   {
        if params.delete(:use_installer)
          wrapped_jnlp_url = polymorphic_url(@investigation, :format => :jnlp, :params => params)
          render :partial => 'shared/show_installer', :locals =>
            { :runnable => @investigation, :teacher_mode => @teacher_mode , :wrapped_jnlp_url => wrapped_jnlp_url }
        else
          render :partial => 'shared/show', :locals => { :runnable => @investigation, :teacher_mode => @teacher_mode }
        end
      }

      format.config { render :partial => 'shared/show', :locals => { :runnable => @investigation, :teacher_mode => @teacher_mode, :session_id => (params[:session] || request.env["rack.session.options"][:id]) } }
      format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @investigation, :teacher_mode => @teacher_mode} }
      format.otml   { render :layout => 'layouts/investigation' } # investigation.otml.haml
      format.xml    { render :xml => @investigation }
      format.pdf    { render :layout => false }
    end
  end

  # GET /investigations/teacher/1.otml
  # GET /investigations/teacher/1.dynamic_otml
  def teacher
    # display for teachers? Later we can determin via roles?
    @teacher_mode = true
    # whay doesn't this work with: respond_to do |format| ??
    if request.format == :otml
      render :layout => 'layouts/investigation', :action => :show
    elsif request.format == :dynamic_otml
      render :partial => 'shared/show', :locals => {:runnable => @investigation, :teacher_mode => @teacher_mode}
    end
  end

  # GET /pages/new
  # GET /pages/new.xml
  def new
    @investigation = Investigation.new
    @investigation.user = current_user
    if APP_CONFIG[:use_gse]
      @gse = RiGse::GradeSpanExpectation.default
      @investigation.grade_span_expectation = @gse
      session[:original_gse_id] = session[:gse_id] = @gse.id
      session[:original_grade_span] = session[:grade_span] = grade_span = @gse.grade_span
      session[:original_domain_id] = session[:domain_id] = @gse.domain.id
      domain = RiGse::Domain.find(@gse.domain.id)
      gses = domain.grade_span_expectations
      @related_gses = gses.find_all { |gse| gse.grade_span == grade_span }
    end
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
    if APP_CONFIG[:use_gse]
      # if there is no gse assign a default one:
      unless @gse = @investigation.grade_span_expectation
        @gse = RiGse::GradeSpanExpectation.default
        @investigation.grade_span_expectation = @gse
        @investigation.save!
      end

      session[:original_gse_id] = session[:gse_id] = @gse.id
      session[:original_grade_span] = session[:grade_span] = grade_span = @gse.grade_span
      session[:original_domain_id] = session[:domain_id] = @gse.domain.id
      domain = RiGse::Domain.find(@gse.domain.id)
      gses = domain.grade_span_expectations
      @related_gses = gses.find_all { |gse| gse.grade_span == grade_span }
    end
    if request.xhr?
      render :partial => 'remote_form', :locals => { :investigation => @investigation,:related_gses => @related_gses, :selected_gse => @gse}
    end
  end

  # POST /pages
  # POST /pages.xml
  def create
    begin
      gse = RiGse::GradeSpanExpectation.find(params[:grade_span_expectation])
      params[:investigation][:grade_span_expectation] = gse
    rescue
      logger.error('could not find gse')
    end
    @investigation = Investigation.new(params[:investigation])
    @investigation.user = current_user
    respond_to do |format|
      if @investigation.save
        flash[:notice] = "#{Investigation.display_name} was successfully created."
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
      @selected_gse = RiGse::GradeSpanExpectation.find_by_id(params[:grade_span_expectation][:id])
      session[:gse_id] = @selected_gse.id
    else
      @selected_gse = RiGse::GradeSpanExpectation.find_by_id(session[:gse_id])
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
    domain = RiGse::Domain.find(domain_id)
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
    update_gse
    if request.xhr?
      if cancel || @investigation.update_attributes(params[:investigation])
        render :partial => 'shared/investigation_header', :locals => { :investigation => @investigation }
      else
        render :xml => @investigation.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @investigation.update_attributes(params[:investigation])
          flash[:notice] = "#{Investigation.display_name} was successfully updated."
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
    if @investigation.changeable?(current_user)
      if @investigation.offerings && @investigation.offerings.size > 0
        flash[:error] = "This #{Investigation.display_name} can't be destoyed, its in use by classes..."
        @failed = true
      else
        @investigation.destroy
      end
    end
    respond_to do |format|
      format.html { redirect_back_or investigation_path(@investigation)}
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
    @activity.investigation = @investigation
    @activity.save
    redirect_to edit_activity_path @activity
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
    flash[:notice] ="Copied #{@original.name}"
    redirect_to url_for(@investigation)
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
    render :partial => 'shared/paste_link', :locals =>{:types => ['activity'],:params => params}
  end

  #
  # In an Investigation controller, we only accept activity clipboard data,
  # see: views/investigations/_paste_link
  #
  def paste
    if @investigation.changeable?(current_user)
      @original = clipboard_object(params)
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

  def usage_report
    sio = get_report(:usage)
    filename = @investigation.id.nil? ? "investigations-published-usage.xls" : "investigation-#{@investigation.id}-usage.xls"
    send_data(sio.string, :type => "application/vnd.ms.excel", :filename => filename )
  end

  def details_report
    sio = get_report(:detail)
    filename = @investigation.id.nil? ? "investigations-published-details.xls" : "investigation-#{@investigation.id}-details.xls"
    send_data(sio.string, :type => "application/vnd.ms.excel", :filename => filename )
  end

  private

  def get_report(type)
    sio = StringIO.new
    opts = {:verbose => false}
    opts[:investigations] = [@investigation] unless @investigation.id.nil?
    opts[:blobs_url] = dataservice_blobs_url
    rep = nil
    case type
    when :detail
      rep = Reports::Detail.new(opts)
    when :usage
      rep = Reports::Usage.new(opts)
    end
    rep.run_report(sio) if rep
    return sio
  end

end
