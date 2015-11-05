class PagesController < ApplicationController
  helper :all

  # so we can use dom_id_for
  include ApplicationHelper

  # PUNDIT_CHECK_FILTERS
  before_filter :find_entities, :except => [:create,:new,:index,:delete_element,:add_element]
  before_filter :render_scope, :only => [:show]
  before_filter :can_edit, :except => [:index,:show,:print,:create,:new]
  before_filter :can_create, :only => [:new, :create]

  in_place_edit_for :page, :name
  in_place_edit_for :page, :description

  protected

  def render_scope
    @render_scope = @page
  end

  def can_create
    if (current_visitor.anonymous?)
      flash[:error] = "Anonymous users can not create pages"
      redirect_back_or pages_path
    end
  end


  def find_entities
    if (params[:id])
      @page = Page.find(params[:id], :include => [:section, :teacher_notes, { :page_elements => :embeddable}])
      if @page
        @section = @page.section
        @@page_title = @page.name
        if @section
          @page_title="#{@section.name} : #{@page.name}"
          @activity =@section.activity
          if @activity
            @investigation = @activity.investigation
          end
        end
      end
      @page_elements = @page.page_elements
    end
    format = request.parameters[:format]
    unless format == 'otml' || format == 'jnlp'
    end
  end

  def can_edit
    if defined? @page
      unless @page.changeable?(current_visitor)
        error_message = "you (#{current_visitor.login}) are not permitted to #{action_name.humanize} (#{@page.name})"
        flash[:error] = error_message
        if request.xhr?
          render :text => "<div class='flash_error'>#{error_message}</div>"
        else
          redirect_back_or investigations_path
        end
      end
    end
  end

  public

  # GET /page
  # GET /page.xml
  def index
    authorize Page
    # @activity = Activity.find(params['section_id'])
    # @pages = @activity.pages
    # @pages = Page.all

    @include_drafts = param_find(:include_drafts)
    @name = param_find(:name)

    pagination = params[:page]
    if (pagination)
       @include_drafts = param_find(:include_drafts)
    else
      @include_drafts = param_find(:include_drafts,true)
    end

    @pages = Page.search_list({
      :name => @name,
      :portal_clazz_id => @portal_clazz_id,
      :include_drafts => @include_drafts,
      :paginate => true,
      :page => pagination
    })
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (did not find instance)
    # @pages = policy_scope(Page)

    if params[:mine_only]
      @pages = @pages.reject { |i| i.user.id != current_visitor.id }
    end

    @paginated_objects = @pages

    if request.xhr?
      render :partial => 'pages/runnable_list', :locals => {:pages => @pages, :paginated_objects => @pages}
    else
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @page }
      end
    end
  end

  # GET /page/1
  # GET /page/1.xml
  def show
    authorize @page
    @teacher_mode = params[:teacher_mode] || @page.teacher_only
    respond_to do |format|
      format.html {
        if params['print']
          render :print, :layout => "layouts/print"
        end
      }
      format.run_sparks_html   { render :show, :layout => "layouts/run" }
      format.run_html   { render :show, :layout => "layouts/run" }
      format.jnlp       { render :partial => 'shared/installer', :locals => { :runnable => @page, :teacher_mode => @teacher_mode } }
      format.config     { render :partial => 'shared/show', :locals => { :runnable => @page, :teacher_mode => @teacher_mode, :session_id => (params[:session] || request.env["rack.session.options"][:id]) } }
      format.otml       { render :layout => "layouts/page" } # page.otml.haml
      format.dynamic_otml {
        learner = (params[:learner_id] ? Portal::Learner.find(params[:learner_id]) : nil)
        if learner && learner.bundle_logger.in_progress_bundle
          launch_event = Dataservice::LaunchProcessEvent.create(
            :event_type => Dataservice::LaunchProcessEvent::TYPES[:activity_otml_requested],
            :event_details => "Activity content loaded. Activity should now be running...",
            :bundle_content => learner.bundle_logger.in_progress_bundle
          )
        end
        render :partial => 'shared/show', :locals => {:runnable => @page, :teacher_mode => @teacher_mode}
      }
      format.xml        { render :xml => @page }
    end
  end


  # GET /page/1/preview
  # GET /page/1.xml
  def preview
    # PUNDIT_REVIEW_AUTHORIZE
    authorize @page, :show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @page }
    end
  end


  # GET /page/

  # GET /page/new.xml
  def new
    authorize Page
    @page = Page.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /page/1/edit
  def edit
    authorize @page
    if request.xhr?
      render :partial => 'remote_form', :locals => { :page => @page, :section => @page.section }
    end
  end


  # POST /page
  # POST /page.xml
  def create
    authorize Page
    @page = Page.create(params[:page])
    @page.user = current_visitor
    respond_to do |format|
      if @page.save
        format.js
        flash[:notice] = 'page was successfully created.'
        format.html { redirect_to(@page) }
        format.xml  { render :xml => @page, :status => :created, :location => @page }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /page/1
  # PUT /page/1.xml
  def update
    authorize @page
    respond_to do |format|
      if @page.update_attributes(params[:page])
        flash[:notice] = 'Page was successfully updated.'
        format.html { redirect_to(@page) }
        format.xml  { head :ok }
        format.js
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /page/1
  # DELETE /page/1.xml
  def destroy
    authorize @page
    @page.destroy
    @redirect = params[:redirect]

    respond_to do |format|
      format.html { redirect_to(page_url) }
      format.js
      format.xml  { head :ok }
    end
  end

  ##
  ## This is a remote_function (ajax) to be called with link_to_remote or similar.
  ## We expect parameters "page_id" and "closs_name"
  ## optional parameter "container" tells us what DOM ID to add our results too...
  ##

  def add_element
    @page = Page.find(params['page_id'])
    authorize @page, :update_edit_or_destroy?
    # @container no longer used?
    @container = params['container']

    # dynamically instantiate the component based on its type.
    component_class = params['class_name'].constantize
    if component_class == Embeddable::DataCollector
      if probe_type_id = session[:last_saved_probe_type_id]
        probe_type = Probe::ProbeType.find(probe_type_id)
        @component = Embeddable::DataCollector.new
        @component.probe_type = probe_type
        @component.name = "Data Collector"
        @component.save
      else
        @component = Embeddable::DataCollector.create(:name => "Data Collector")
      end
      session[:last_saved_probe_type_id] = @component.probe_type_id
    else
      @component = component_class.create
    end
    @component.create_default_choices if component_class == Embeddable::MultipleChoice
    @component.pages << @page
    @component.user = current_visitor
    @component.save
    @element = @page.element_for(@component)
    @element.user = current_visitor
    @element.save

    #
    # # dynamically insert appropriate partial based on type.
    # @partial = partial_for(@component)

    # we will render page/add_element.js.rjs by default....
    # this rjs will include the appropriate html fragment
  end

  ##
  ##
  ##
  def sort_elements
    authorize @page, :update_edit_or_destroy?
    key_name = 'elements_container'
    params.each_key do |k|
      key_name = k if k =~ /elements_container/
    end
    @page.page_elements.each do |element|
      element_index = params[key_name].index(element.id.to_s)
      if element_index
        element.position = element_index + 1
        element.save
      end
    end
    render :update do |page|
      page << "flatten_sortables();"
    end
  end


  ##
  ##
  ##
  def duplicate
    # PUNDIT_REVIEW_AUTHORIZE
    authorize Page, :new_or_create?
    @copy = @page.deep_clone :no_duplicates => true, :never_clone => [:uuid, :created_at, :updated_at]
    @copy.name = "" #force numbering by default
    @copy.save
    flash[:notice] ="Copied #{@page.name}"
    redirect_to url_for(@copy)
  end


  def paste_link
    # no authorization needed ...
    render :partial => 'shared/paste_link', :locals =>{:types => Page.paste_acceptable_types,:params => params}
  end

  #
  # Paste a page component
  #
  def paste
    authorize @page, :update_edit_or_destroy?
    if @page.changeable?(current_visitor)
      @original = clipboard_object(params)
      if (@original)
        # let some embeddables define their own means to save
        if @original.respond_to? :duplicate
          @component = @original.duplicate
        else
          @component = @original.deep_clone :no_duplicates => true, :never_clone => [:uuid, :updated_at,:created_at]
        end
        if (@component)
          @container = params['container'] || dom_id_for(@page, :elements_container)
          @component.name = "copy of #{@component.name}"
          @component.user = @page.user
          @component.pages << @page
          @component.save
          @element = @page.element_for(@component)
          @element.user = @component.user
          @element.save
        end
      end
      if @element.nil?
        logger.warn "Paste failed. original: #{@original} container: #{@container} component: #{@component} element: #{@element}"
      else
        render :update do |page|
          page.insert_html :bottom, @container, render(:partial => 'element_container', :locals => {:edit => true, :page_element => @element, :component => @component, :page => @page })
          page.sortable 'elements_container', :url=> {:action => 'sort_elements', :params => {:page_id => @page.id }}
          page[dom_id_for(@component, :item)].scrollTo()
          page.visual_effect :highlight, dom_id_for(@component, :item)
        end
      end
    end
  end
end
