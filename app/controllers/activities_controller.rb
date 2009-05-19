class ActivitiesController < ApplicationController
  # GET /pages
  # GET /pages.xml
  prawnto :prawn=>{
    :page_layout=>:landscape,
  }
  before_filter :setup_object, :except => [:index]

  # editing / modifying / deleting require editable-ness
  before_filter :can_edit, :except => [:index,:show,:print,:create,:new,:duplicate,:export]
  
  in_place_edit_for :activity, :name
  in_place_edit_for :activity, :description
  
  protected  

  def can_edit
    if defined? @activity
      unless @activity.changeable?(current_user)
        error_message = "you (#{current_user.login}) can not #{action_name.humanize} #{@activity.name}"
        flash[:error] = error_message
        if request.xhr?
          render :text => "<div class='flash_error'>#{error_message}</div>"
        else
          redirect_back_or activities_path
        end
      end
    end
  end
  
  
  def setup_object
    if params[:id]
      if params[:id].length == 36
        @activity = Activity.find(:first, :conditions => ['uuid=?',params[:id]])
      else
        @activity = Activity.find(params[:id])
      end
    elsif params[:activity]
      @activity = Activity.new(params[:activity])
    else
      @activity = Activity.new
    end
    format = request.parameters[:format]
    unless format == 'otml' || format == 'jnlp'
      if @activity
        teacher_note = @activity.teacher_note || TeacherNote.new
        teacher_note.authored_entity = @activity
        author_note = @activity.author_note || AuthorNote.new
        author_note.authored_entity = @activity 
        @teacher_note = render_to_string :partial => 'teacher_notes/remote_form', :locals => {:teacher_note => teacher_note}
        @author_note = render_to_string :partial => 'author_notes/remote_form', :locals => {:author_note => author_note}
      end
    end
  end
  
  public
  
  def index
    if params[:mine_only]
      @pages = Activity.search(params[:search], params[:page], self.current_user)
    else
      @pages = Activity.search(params[:search], params[:page], nil)
    end
    @paginated_objects = @pages    

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pages }
    end
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    @activity = Activity.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @activity }
      format.otml { render :layout => 'layouts/activity' } # activity.otml.haml
      format.jnlp { render :layout => false }
      format.pdf {render :layout => false }
    end
  end

  # GET /activities/1/print
  def print
    respond_to do |format|
      format.html { render :layout => "layouts/print" }
      format.xml  { render :xml => @page }
    end
  end

  # GET /pages/new
  # GET /pages/new.xml
  def new
    @activity = Activity.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @activity }
    end
  end

  # GET /pages/1/edit
  def edit
    @activity = Activity.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :activity => @activity }
    end
  end

  # POST /pages
  # POST /pages.xml
  def create
    @activity = Activity.new(params[:activity])
    @activity.user = current_user
    respond_to do |format|
      if @activity.save
        format.js  # render the js file
        flash[:notice] = 'Activity was successfully created.'
        format.html { redirect_to(@activity) }
        format.xml  { render :xml => @activity, :status => :created, :location => @activity }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @activity = Activity.find(params[:id])
    if request.xhr?
      if cancel || @activity.update_attributes(params[:activity])
        render :partial => 'shared/activity_header', :locals => { :activity => @activity }
      else
        render :xml => @activity.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @activity.update_attributes(params[:activity])
          flash[:notice] = 'Activity was successfully updated.'
          format.html { redirect_to(@activity) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
        end
      end
    end
  end
  

  # DELETE /pages/1
  # DELETE /pages/1.xml
  def destroy
    @activity = Activity.find(params[:id])
    @activity.destroy

    respond_to do |format|
      format.html { redirect_back_or(activities_url) }
      format.xml  { head :ok }
    end
  end
  
  ##
  ##
  ##
  def add_section
    @section = Section.new
    @activity = Activity.find(params['id'])
    @section.activity = @activity
  end
  
  ##
  ##
  ##  
  def sort_sections
    paramlistname = params[:list_name].nil? ? 'activity_sections_list' : params[:list_name]    
    @activity = Activity.find(params[:id], :include => :sections)
    @activity.sections.each do |section|
      section.position = params[paramlistname].index(section.id.to_s) + 1
      section.save
    end 
    render :nothing => true
  end

  ##
  ##
  ##
  def delete_section
    @section= Section.find(params['section_id'])
    @section.destroy
  end  
  
  ##
  ##
  ##
  def duplicate
    @original = Activity.find(params['id'])
    @activity = @original.clone :include => {:sections => {:pages => {:page_elements => :embeddable}}}
    @activity.name = "copy of #{@activity.name}"
    @activity.deep_set_user current_user
    @activity.save
    redirect_to edit_activity_url(@activity)
  end
  
  def export
    respond_to do |format|
      format.xml  { 
        send_data @activity.deep_xml, :type => :xml, :filename=>"#{@activity.name}.xml"
      }
    end
  end
  
end
