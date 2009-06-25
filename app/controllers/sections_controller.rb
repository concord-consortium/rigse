class SectionsController < ApplicationController
  
  before_filter :find_entities, :except => ['create','new']
  in_place_edit_for :section, :name
  in_place_edit_for :section, :description
  
  before_filter :can_edit, :except => [:index,:show,:print,:create,:new]
  before_filter :can_create, :only => [:new, :create]
  protected 
  
  def can_create
    if (current_user.anonymous?)
      flash[:error] = "Anonymous users can not create sections"
      redirect_back_or sections_path
    end
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
          teacher_note = @section.teacher_note || TeacherNote.new
          teacher_note.authored_entity = @section
          author_note = @section.author_note || AuthorNote.new
          author_note.authored_entity = @section 
          @teacher_note = render_to_string :partial => 'teacher_notes/remote_form', :locals => {:teacher_note => teacher_note}
          @author_note = render_to_string :partial => 'author_notes/remote_form', :locals => {:author_note => author_note}
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
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @section }
    end
  end

  ##
  ##
  ##
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.otml { render :layout => 'layouts/section' } # section.otml.haml
      format.jnlp { render :layout => false }
      format.xml  { render :xml => @section }
    end
  end

  # GET /sections/1/print
  def print
    respond_to do |format|
      format.html { render :layout => "layouts/print" }
      format.xml  { render :xml => @page }
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
        @xhtml = Xhtml.create
        @xhtml.user = current_user
        @xhtml.save!
        @xhtml.pages << @page
        @section.pages << @page
        @section.save
        @section.update_investigation_timestamp
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
        @section.update_investigation_timestamp
        render :partial => 'shared/section_header', :locals => { :section => @section }
      else
        render :xml => @section.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @section.update_attributes(params[:section])
          @section.update_investigation_timestamp
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
    @section.update_investigation_timestamp
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
    @page= Page.new
    if (params['id']) 
      @section = Section.find(params['id'])
      @page.section = @section
      @page.save
    end
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
    @activity = @copy.activity
    redirect_to :action => 'edit', :id => @copy.id
  end
  
  #
  # Construct a link suitable for a 'paste' action in this controller.
  #
  def paste_link
    render :partial => 'shared/paste_link', :locals =>{:types => ['page'],:parmas => params}
  end

  #
  # In a section controller, we only accept page clipboard data,
  # 
  def paste
    if @section.changeable?(current_user)
      clipboard_data_type = params[:clipboard_data_type] || cookies[:clipboard_data_type]
      clipboard_data_id = params[:clipboard_data_id] || cookies[:clipboard_data_id]
      klass = clipboard_data_type.pluralize.classify.constantize
      @original = klass.find(clipboard_data_id)
      if (@original) 
        @component = @original.clone :include =>  {:page_elements => :embeddable}
        if (@component)
          # @component.original = @original
          @container = params[:container] || 'section_pages_list'
          @component.name = "copy of #{@component.name}"
          @component.deep_set_user current_user
          @component.save
        end
      end
    end
    render :update do |page|
      page.insert_html :bottom, @container, render (:partial => 'page_list_item', :locals => {:page => @component})
      page.sortable :section_pages_list, :handle=> 'sort-handle', :dropOnEmpty => true, :url=> {:action => 'sort_pages', :params => {:section_id => @section.id }}
      page[dom_id_for(@component, :item)].scrollTo()
      page.visual_effect :highlight, dom_id_for(@component, :item)
    end
  end  
end
