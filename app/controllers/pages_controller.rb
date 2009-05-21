class PagesController < ApplicationController
  helper :all
  
  before_filter :find_entities, :except => ['create','new','index','delete_element','add_element']
  before_filter :can_edit, :except => [:index,:show,:print,:create,:new]
    
  in_place_edit_for :page, :name
  in_place_edit_for :page, :description
    
  protected 
  
  def find_entities
    if (params[:id])
      @page = Page.find(params[:id], :include => [:section, :teacher_notes, { :page_elements => :embeddable}])
      if @page
        @section = @page.section
        if @section
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
        error_message = "you (#{current_user.login}) is not permitted to #{action_name.humanize} (#{@page.name})"
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

    # dynamically instatiate the component based on its type.
    @component = Kernel.const_get(params['class_name']).create
    @component.pages << @page
    @component.save
    @element = @page.element_for(@component)
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


end
