class ExternalActivitiesController < ApplicationController

  before_filter :setup_object, :except => [:index]
  before_filter :render_scope, :only => [:show]
  # editing / modifying / deleting require editable-ness
  before_filter :can_edit, :except => [:index,:show,:print,:create,:new,:duplicate,:export] 
  before_filter :can_create, :only => [:new, :create,:duplicate]
  
  in_place_edit_for :external_activity, :name
  in_place_edit_for :external_activity, :description
  in_place_edit_for :external_activity, :url

  protected  

  def can_create
    if (current_user.anonymous?)
      flash[:error] = "Anonymous users can not create external external_activities"
      redirect_back_or external_activities_path
    end
  end
  
  def render_scope
    @render_scope = @external_activity
  end

  def can_edit
    if defined? @external_activity
      unless @external_activity.changeable?(current_user)
        error_message = "you (#{current_user.login}) can not #{action_name.humanize} #{@external_activity.name}"
        flash[:error] = error_message
        if request.xhr?
          render :text => "<div class='flash_error'>#{error_message}</div>"
        else
          redirect_back_or external_activities_path
        end
      end
    end
  end
  
  
  def setup_object
    if params[:id]
      if params[:id].length == 36
        @external_activity = ExternalActivity.find(:first, :conditions => ['uuid=?',params[:id]])
      else
        @external_activity = ExternalActivity.find(params[:id])
      end
    elsif params[:external_activity]
      @external_activity = ExternalActivity.new(params[:external_activity])
    else
      @external_activity = ExternalActivity.new
    end
    @page_title = @external_activity.name if @external_activity
  end
  
  public
  
  def index
    @include_drafts = params[:include_drafts]
    @name = param_find(:name)
    pagination = params[:page]
    if (pagination)
      @include_drafts = param_find(:include_drafts)
    else
      @include_drafts = param_find(:include_drafts,true)
    end
    @external_activities = ExternalActivity.search_list({
      :name => @name, 
      :description => @description, 
      :paginate => true, 
      :page => pagination
    })
    if params[:mine_only]
      @external_activities = @external_activities.reject { |i| i.user.id != current_user.id }
    end
    @paginated_objects = @external_activities

    if request.xhr?
      render :partial => 'external_activities/runnable_list', :locals => {:external_activities => @external_activities, :paginated_objects => @external_activities}
    else
      respond_to do |format|
        format.html do
          render 'index'
        end
        format.js
      end
    end
  end
  
  # GET /external_activities/1
  # GET /external_activities/1.xml
  def show
    # @teacher_mode = params[:teacher_mode] || @external_activity.teacher_only
    respond_to do |format|
      format.html {
        if params['print'] 
          render :print, :layout => "layouts/print"
        end
      }
      format.run_external_html   { redirect_to(@external_activity.url) }
      format.xml  { render :xml => @external_activity }
    end
  end

  # GET /external_activities/new
  # GET /external_activities/new.xml
  def new
    @external_activity = ExternalActivity.new
    @external_activity.user = current_user
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @external_activity }
    end
  end
  
  # GET /external_activities/1/edit
  def edit
    @external_activity = ExternalActivity.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :external_activity => @external_activity }
    end
  end
  
  # POST /pages
  # POST /pages.xml
  def create
    @external_activity = ExternalActivity.new(params[:external_activity])
    @external_activity.user = current_user
    respond_to do |format|
      if @external_activity.save
        format.js  # render the js file
        flash[:notice] = 'ExternalActivity was successfully created.'
        format.html { redirect_to(@external_activity) }
        format.xml  { render :xml => @external_activity, :status => :created, :location => @external_activity }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @external_activity.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /external_activities/1
  # PUT /external_activities/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @external_activity = ExternalActivity.find(params[:id])
    if request.xhr?
      if cancel || @external_activity.update_attributes(params[:external_activity])
        render :partial => 'shared/external_activity_header', :locals => { :external_activity => @external_activity }
      else
        render :xml => @external_activity.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @external_activity.update_attributes(params[:external_activity])
          flash[:notice] = 'ExternalActivity was successfully updated.'
          format.html { redirect_to(@external_activity) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @external_activity.errors, :status => :unprocessable_entity }
        end
      end
    end
  end
  
  
  # DELETE /external_activities/1
  # DELETE /external_activities/1.xml
  def destroy
    @external_activity = ExternalActivity.find(params[:id])
    @external_activity.destroy
    @redirect = params[:redirect]
    respond_to do |format|
      format.html { redirect_back_or(external_activities_url) }
      format.js
      format.xml  { head :ok }
    end
  end
  
  
  ##
  ##
  ##
  def duplicate
    @original = ExternalActivity.find(params['id'])
    @external_activity = @original.deep_clone :no_duplicates => true, :never_clone => [:uuid, :created_at, :updated_at], :include => [{:teacher_notes => {}}, {:author_notes => {}}]
    @external_activity.name = "copy of #{@external_activity.name}"
    @external_activity.user = current_user
    @external_activity.save

    (@external_activity.teacher_notes + @external_activity.author_notes).each {|tn| n.user = current_user; n.save }

    flash[:notice] ="Copied #{@original.name}"
    redirect_to url_for(@external_activity)
  end
  
end
