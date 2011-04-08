class SectionsController < ApplicationController
  toggle_controller_for :sections
  before_filter :find_entities, :except => ['create','new']
  in_place_edit_for :section, :name
  in_place_edit_for :section, :description
  before_filter :render_scope, :only => [:show]
  before_filter :can_edit, :except => [:index,:show,:print,:create,:new]
  before_filter :can_create, :only => [:new, :create]
  protected 
  def can_create
    if (current_user.anonymous?)
      flash[:error] = "Anonymous users can not create sections"
      redirect_back_or sections_path
    end
  end
  def render_scope
    @render_scope = @section
  end
  def find_entities
    if (params[:id])
      @section = Section.find(params[:id], :include=> {:pages => {:page_elements => :embeddable}})
      format = request.parameters[:format]
      unless format == 'otml' || format == 'jnlp'
        if @section
          @page_title=@section.name
          @activity = @section.activity
          if @activity 
            @investigation = @activity.investigation
          end
        end
      end
    end
  end
  
  def can_edit
    if defined? @section
      unless @section.changeable?(current_user)
        error_message = "you (#{current_user.login}) can not #{action_name.humanize} #{@section.name}"
        flash[:error] = error_message
        if request.xhr?
          render :text => "<div class='flash_error'>#{error_message}</div>"
        else
          redirect_back_or sections_paths
      end
    end
    end
  end
  
  
  public
  
  ##
  ##
  ##
  def index
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
      @sections = @sections.reject { |i| i.user.id != current_user.id }
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
    @teacher_mode = params[:teacher_mode]
    respond_to do |format|
      format.html {
        if params['print'] 
          render :print, :layout => "layouts/print"
        end
      }
      format.jnlp   { render :partial => 'shared/show', :locals => { :runnable => @section, :teacher_mode => @teacher_mode } }
      format.config { render :partial => 'shared/show', :locals => { :runnable => @section, :teacher_mode => @teacher_mode, :session_id => (params[:session] || request.env["rack.session.options"][:id]) } }      
      format.otml { render :layout => 'layouts/section' } # section.otml.haml
      format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @section, :teacher_mode => @teacher_mode} }
      format.xml  { render :xml => @section }
    end
  end


  ##
  ##
  ##
  def new
    @section = Section.new
    @section.user = current_user
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @section }
    end
  end

  ##
  ##
  ##
  def create
    @section = Section.create!(params[:section])
    @section.user = current_user
    respond_to do |format|
      format.js {
        @page = Page.create
        @page.user = current_user
        @xhtml = Embeddable::Xhtml.create
        @xhtml.user = current_user
        @xhtml.save!
        @xhtml.pages << @page
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
    if request.xhr?
      render :partial => 'remote_form', :locals => { :section => @section, :activity => @section.activity }
    end
  end
  
  ##
  ##
  ##
  def update
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
    @page= Page.create
    @page.section = @section
    @page.user = current_user
    @page.save
    redirect_to @page
  end
  
  ##
  ##
  ##  
  def sort_pages
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
    @page= Page.find(params['page_id'])
    @page.destroy
  end
  
  ##
  ##
  ##
  def duplicate
    @copy = @section.clone :include => {:pages => {:page_elements => :embeddable}}
    @copy.name = "copy of #{@section.name}"
    @copy.save
    @copy.deep_set_user current_user
    @activity = @copy.activity
    flash[:notice] ="Copied #{@section.name}"
    redirect_to url_for(@copy)
  end
  
  #
  # Construct a link suitable for a 'paste' action in this controller.
  #
  def paste_link
    render :partial => 'shared/paste_link', :locals =>{:types => ['page'],:params => params}
  end

  #
  # In a section controller, we only accept page clipboard data,
  # 
  def paste
    if @section.changeable?(current_user)
      @original = clipboard_object(params)
      if @original
        @container = params[:container] || 'section_pages_list'
        if @original.class == Page
          @component = @original.duplicate
        else
          @component = @original.clone :include =>  {:page_elements => :embeddable}
          @component.name = "copy of #{@original.name}"
        end
        if (@component)
          # @component.original = @original
          @component.section = @section
          @component.save
        end
        @component.deep_set_user current_user
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
