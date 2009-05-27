class PagesController < ApplicationController
  helper :all
  
  before_filter :find_entities, :except => ['create','new','index','delete_element','add_element']
  before_filter :can_edit, :except => [:index,:show,:print,:create,:new]
  before_filter :can_create, :only => [:new, :create]
  
  in_place_edit_for :page, :name
  in_place_edit_for :page, :description
    
  protected 
  
  def can_create
    if (current_user.anonymous?)
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
      unless @page.changeable?(current_user)
        error_message = "you (#{current_user.login}) are not permitted to #{action_name.humanize} (#{@page.name})"
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
    # @activity = Activity.find(params['section_id'])
    # @pages = @activity.pages
    @pages = Page.find(:all)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /page/1
  # GET /page/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.otml { render :layout => "layouts/page" } # page.otml.haml
      format.jnlp { render :layout => false }
      format.xml  { render :xml => @page }
    end
  end


  def show_teacher_note
    if @page.teacher_note.nil?
      @page.teacher_note = TeacherNote.create 
      # TODO: Who owns the teacher note? is this correct?
      @page.teacher_note.author = current_user
      @page.save
    end
    if @page.teacher_note.author == current_user
      render :update do |page|
          page.replace_html  'teacher_note', :partial => 'teacher_notes/remote_form', :locals => { :teacher_note => @page.teacher_note}
          page.visual_effect :toggle_blind, 'note'
      end
    else
      render :update do |page|
        page.replace_html  'note', :partial => 'teacher_notes/remote_form', :locals => { :teacher_note => @page.teacher_note}
        page.visual_effect :toggle_blind, 'note'
      end
    end
  end


  # GET /page/1/preview
  # GET /page/1.xml
  def preview
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /page/1/print
  def print
    respond_to do |format|
      format.html { render :layout => "layouts/print" }
      format.xml  { render :xml => @page }
    end
  end

  # GET /page/
  
  # GET /page/new.xml
  def new
    @page = Page.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /page/1/edit
  def edit
    if request.xhr?
      render :partial => 'remote_form', :locals => { :page => @page, :section => @page.section }
    end
  end

  
  # POST /page
  # POST /page.xml
  def create
    @page = Page.create(params[:page])
    respond_to do |format|
      if @page.save
        format.js
        flash[:notice] = 'PageEmbedables was successfully created.'
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
    @container = params['container'] || 'elements_container'

    # dynamically instantiate the component based on its type.
    component_class = Kernel.const_get(params['class_name'])
    if component_class == DataCollector
      if probe_type_id = session[:last_saved_probe_type_id]
        probe_type = ProbeType.find(probe_type_id)
        @component = DataCollector.new
        @component.probe_type = probe_type
        @component.save
      else
        @component = DataCollector.create
      end
      session[:last_saved_probe_type_id] = @component.probe_type_id
    else
      @component = component_class.create
    end
    @component.pages << @page
    @component.user = current_user
    @component.save
    @element = @page.element_for(@component)
    @element.user = current_user
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
    @page.page_elements.each do |element|
      element.position = params['elements_container'].index(element.id.to_s) + 1
      element.save
    end 
    render :nothing => true
  end


  ##
  ##
  ##
  def duplicate
    @copy = @page.clone :include => {:page_elements => :embeddable}
    @copy.name = "copy of #{@page.name}"
    @copy.save
    @section = @copy.section
    redirect_to :action => 'edit', :id => @copy.id
  end


  def paste_link
    render :partial => 'pages/paste_link', :locals => {:params => params}
  end
  
  
  #
  # Must be  js method, so don't even worry about it.
  #
  def paste
    if @page.changeable?(current_user)
      clipboard_data_type = params[:clipboard_data_type] || cookies[:clipboard_data_type]
      clipboard_data_id = params[:clipboard_data_id] || cookies[:clipboard_data_id]
      klass = clipboard_data_type.pluralize.classify.constantize
      @original = klass.find(clipboard_data_id)
      if (@original) 
        @component = @original.clone 
        if (@component)
          @container = params['container'] || 'elements_container'
          @component.name = "copy of #{@component.name}"
          @component.user = @page.user
          @component.pages << @page
          @component.save
          @element = @page.element_for(@component)
        end
      end
    end
  end
end
