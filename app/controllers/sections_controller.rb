class SectionsController < ApplicationController

  before_filter :find_entities, :except => ['create','new']
  in_place_edit_for :section, :name
  in_place_edit_for :section, :description

  before_filter :render_scope, :only => [:show]

  protected

  def not_authorized_error_message
    super({resource_type: 'section', resource_name: @section ? @section.name : nil})
  end

  def render_scope
    @render_scope = @section
  end

  def find_entities
    if (params[:id])
      @section = Section.find(params[:id], :include=> :pages)
      format = request.parameters[:format]
      if @section
        @page_title=@section.name
        @activity = @section.activity
        if @activity
          @investigation = @activity.investigation
        end
      end
    end
  end

  public

  ##
  ##
  ##
  def index
    authorize Section
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (did not find instance)
    # @sections = policy_scope(Section)
    @include_drafts = param_find(:include_drafts)
    @name = param_find(:name)

    pagination = params[:page]
    if (pagination)
       @include_drafts = param_find(:include_drafts)
    else
      @include_drafts = param_find(:include_drafts,true)
    end

    @sections = Section.search_list({
      :name => @name,
      :portal_clazz_id => @portal_clazz_id,
      :include_drafts => @include_drafts,
      :paginate => true,
      :page => pagination
    })

    if params[:mine_only]
      @sections = @sections.reject { |i| i.user.id != current_visitor.id }
    end

    @paginated_objects = @sections

    if request.xhr?
      render :partial => 'sections/runnable_list', :locals => {:sections => @sections, :paginated_objects => @sections}
    else
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @section }
      end
    end
  end

  ##
  ##
  ##
  def show
    authorize @section
    @teacher_mode = params[:teacher_mode]
    respond_to do |format|
      format.run_html   { render :show, :layout => "layouts/run" }
      format.html {
        if params['print']
          render :print, :layout => "layouts/print"
        end
      }
      format.jnlp   { render :partial => 'shared/installer', :locals => { :runnable => @section, :teacher_mode => @teacher_mode } }
      format.config { render :partial => 'shared/show', :locals => { :runnable => @section, :teacher_mode => @teacher_mode, :session_id => (params[:session] || request.env["rack.session.options"][:id]) } }
      format.xml  { render :xml => @section }
      format.json { render :json => @section }
    end
  end


  ##
  ##
  ##
  def new
    authorize Section
    @section = Section.new
    @section.user = current_visitor
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @section }
    end
  end

  ##
  ##
  ##
  def create
    authorize Section
    @section = Section.create!(params[:section])
    @section.user = current_visitor
    respond_to do |format|
      format.js {
        @page = Page.create
        @page.user = current_visitor
        @section.pages << @page
        @section.save
      }
      format.html {
        flash[:notice] = 'Section was successfully created.'
        redirect_to(@section) }
      format.xml  { render :xml => @section, :status => :created, :location => @section }
    end
  end

  # GET /pages/1/edit
  def edit
    authorize @section
    if request.xhr?
      render :partial => 'remote_form', :locals => { :section => @section, :activity => @section.activity }
    end
  end

  ##
  ##
  ##
  def update
    authorize @section
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if @section.update_attributes(params[:section])
        render :partial => 'shared/section_header', :locals => { :section => @section }
      else
        render :xml => @section.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @section.update_attributes(params[:section])
          flash[:notice] = 'Section was successfully updated.'
          format.html { redirect_to(@section) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @section.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  ##
  ##
  ##
  def destroy
    authorize @section
    @section.destroy
    @redirect = params[:redirect]
    respond_to do |format|
      format.html { redirect_to(page_url) }
      format.js
      format.xml  { head :ok }
    end
  end


  ##
  ##
  ##
  def add_page
    authorize @section, :update?
    @page= Page.create
    @page.section = @section
    @page.user = current_visitor
    @page.save
    redirect_to @page
  end

  ##
  ##
  ##
  def sort_pages
    authorize @section, :update?
    paramlistname = params[:list_name].nil? ? 'section_pages_list' : params[:list_name]
    @section.pages.each do |page|
      page.position = params[paramlistname].index(page.id.to_s) + 1
      page.save
    end
    render :nothing => true
  end

  ##
  ##
  ##
  def delete_page
    authorize @section, :update?
    @page= Page.find(params['page_id'])
    @page.destroy
  end

  ##
  ##
  ##
  def duplicate
    authorize Section, :new_or_create?
    @copy = @section.deep_clone :no_duplicates => true, :never_clone => [:uuid, :created_at, :updated_at], :include => :pages
    @copy.name = "copy of #{@section.name}"
    @copy.save
    @copy.deep_set_user current_visitor
    @activity = @copy.activity
    flash[:notice] ="Copied #{@section.name}"
    redirect_to url_for(@copy)
  end

  #
  # Construct a link suitable for a 'paste' action in this controller.
  #
  def paste_link
    # no authorization needed
    render :partial => 'shared/paste_link', :locals =>{:types => ['page'],:params => params}
  end

  #
  # In a section controller, we only accept page clipboard data,
  #
  def paste
    # no authorization applied as the method must always render
    if @section.changeable?(current_visitor)
      @original = clipboard_object(params)
      if @original
        @container = params[:container] || 'section_pages_list'
        if @original.class == Page
          @component = @original.duplicate
        else
          @component = @original.deep_clone :no_duplicates => true, :never_clone => [:uuid, :updated_at,:created_at]
          @component.name = "copy of #{@original.name}"
        end
        if (@component)
          # @component.original = @original
          @component.section = @section
          @component.save
        end
        @component.deep_set_user current_visitor
      end
    end
    render :update do |page|
      page.insert_html :bottom, @container, render(:partial => 'page_list_item', :locals => {:page => @component})
      page.sortable :section_pages_list, :handle=> 'sort-handle', :dropOnEmpty => true, :url=> {:action => 'sort_pages', :params => {:section_id => @section.id }}
      page[dom_id_for(@component, :item)].scrollTo()
      page.visual_effect :highlight, dom_id_for(@component, :item)
    end
  end
end
