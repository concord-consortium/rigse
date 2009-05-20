class InvestigationsController < ApplicationController
  # GET /pages
  # GET /pages.xml
  prawnto :prawn=>{
    :page_layout=>:landscape,
  }
  before_filter :setup_object, :except => [:index]

  # editing / modifying / deleting require editable-ness
  before_filter :can_edit, :except => [:index,:show,:print,:create,:new,:duplicate,:export]
  
  in_place_edit_for :investigation, :name
  in_place_edit_for :investigation, :description
  
  protected  

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
    format = request.parameters[:format]
    unless format == 'otml' || format == 'jnlp'
      if @investigation
        teacher_note = @investigation.teacher_note || TeacherNote.new
        teacher_note.authored_entity = @investigation
        author_note = @investigation.author_note || AuthorNote.new
        author_note.authored_entity = @investigation 
        @teacher_note = render_to_string :partial => 'teacher_notes/remote_form', :locals => {:teacher_note => teacher_note}
        @author_note = render_to_string :partial => 'author_notes/remote_form', :locals => {:author_note => author_note}
      end
    end
  end
  
  public
  
  def index
    if params[:mine_only]
      @pages = Investigation.search(params[:search], params[:page], self.current_user)
    else
      @pages = Investigation.search(params[:search], params[:page], nil)
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
    @investigation = Investigation.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @investigation }
      format.otml { render :layout => 'layouts/investigation' } # investigation.otml.haml
      format.jnlp { render :layout => false }
      format.pdf {render :layout => false }
    end
  end

  # GET /investigations/1/print
  def print
    respond_to do |format|
      format.html { render :layout => "layouts/print" }
      format.xml  { render :xml => @investigation }
    end
  end

  # GET /pages/new
  # GET /pages/new.xml
  def new
    @investigation = Investigation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @investigation }
    end
  end

  # GET /pages/1/edit
  def edit
    @investigation = Investigation.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :investigation => @investigation }
    end
  end

  # POST /pages
  # POST /pages.xml
  def create
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

  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    cancel = params[:commit] == "Cancel"
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
      format.xml  { head :ok }
    end
  end
  
  ##
  ##
  ##
  def add_activity
    @activity = Activity.new
    @investigation = Investigation.find(params['id'])
    @activity.investigation = @investigation
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
    @activity.destroy
  end  
  
  ##
  ##
  ##
  def duplicate
    @original = Investigation.find(params['id'])
    @investigation = @original.clone :include => {:activities => {:sections => {:pages => {:page_elements => :embeddable}}}}
    @investigation.name = "copy of #{@investigation.name}"
    @investigation.deep_set_user current_user
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
  
end
