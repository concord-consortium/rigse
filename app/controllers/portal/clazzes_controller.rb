class Portal::ClazzesController < ApplicationController
  # GET /portal_clazzes
  # GET /portal_clazzes.xml
  def index
    @portal_clazzes = Portal::Clazz.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @portal_clazzes }
    end
  end

  # GET /portal_clazzes/1
  # GET /portal_clazzes/1.xml
  def show
    @portal_clazz = Portal::Clazz.find(params[:id])
    @teacher = @portal_clazz.parent
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @portal_clazz }
    end
  end

  # GET /portal_clazzes/new
  # GET /portal_clazzes/new.xml
  def new
    @semesters = Portal::Semester.find(:all)
    @portal_clazz = Portal::Clazz.new
    if params[:teacher_id]
      @portal_clazz.teacher = Portal::Teacher.find(params[:teacher_id])
    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @portal_clazz }
    end
  end

  # GET /portal_clazzes/1/edit
  def edit
    @portal_clazz = Portal::Clazz.find(params[:id])
    @semesters = Portal::Semester.find(:all)
    if request.xhr?
      render :partial => 'remote_form', :locals => { :portal_clazz => @portal_clazz }
    end
  end

  # POST /portal_clazzes
  # POST /portal_clazzes.xml
  def create
    @portal_clazz = Portal::Clazz.new(params[:portal_clazz])
    respond_to do |format|
      if @portal_clazz.save
        flash[:notice] = 'Portal::Clazz was successfully created.'
        format.html { redirect_to(@portal_clazz) }
        format.xml  { render :xml => @portal_clazz, :status => :created, :location => @portal_clazz }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @portal_clazz.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /portal_clazzes/1
  # PUT /portal_clazzes/1.xml
  def update
    @portal_clazz = Portal::Clazz.find(params[:id])
    if request.xhr?
      @portal_clazz.update_attributes(params[:portal_clazz])
      render :partial => 'show', :locals => { :portal_clazz => @portal_clazz }
    else
      respond_to do |format|
        if @portal_clazz.update_attributes(params[:portal_portal_clazz])
          flash[:notice] = 'Portal::Clazz was successfully updated.'
          format.html { redirect_to(@portal_clazz) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @portal_clazz.errors, :status => :unprocessable_entity }
        end
      end
    end
  end  

  # DELETE /portal_clazzes/1
  # DELETE /portal_clazzes/1.xml
  def destroy
    @portal_clazz = Portal::Clazz.find(params[:id])
    @portal_clazz.destroy
    respond_to do |format|
      format.html { redirect_to(portal_clazzes_url) }
      format.js
      format.xml  { head :ok }
    end
  end
  
  ## END OF CRUD METHODS
  def edit_offerings
    @portal_clazz = Portal::Clazz.find(params[:id])
    @grade_span = session[:grade_span] ||= cookies[:grade_span]
    @domain_id = session[:domain_id] ||= cookies[:domain_id]
  end
  
  # HACK:
  # TODO: (IMPORTANT:) This  method is currenlty only for ajax requests, and uses dom_ids 
  # TODO: to infer runnables. Rewrite this, so that the params are less JS/DOM specific..
  def add_offering
    @portal_clazz = Portal::Clazz.find(params[:id])
    dom_id = params[:dragged_dom_id]
    container = params[:dropped_dom_id]
    runnable_id = params[:runnable_id]
    unless params[:runnable_type] == 'portal_offering'
      runnable_type = params[:runnable_type].classify
      @offering = Portal::Offering.find_or_create_by_clazz_id_and_runnable_type_and_runnable_id(@portal_clazz.id,runnable_type,runnable_id)
      if @offering
        @offering.save
        @portal_clazz.reload
      end
      render :update do |page|
        page << "var element = $('#{dom_id}');"
        page << "element.remove();"
        page.insert_html :top, container, :partial => 'shared/offering_for_teacher', :locals => {:offering => @offering}
      end
    end
  end
  
  # HACK:
  # TODO: (IMPORTANT:) This  method is currenlty only for ajax requests, and uses dom_ids 
  # TODO: to infer runnables. Rewrite this, so that the params are less JS/DOM specific..
  def remove_offering
    @portal_clazz = Portal::Clazz.find(params[:id])
    dom_id = params[:dragged_dom_id]
    container = params[:dropped_dom_id]
    offering_id = params[:offering_id]
    @offering = Portal::Offering.find(offering_id)
    if @offering
      @runnable = @offering.runnable
      @offering.destroy
      @portal_clazz.reload
    end
    render :update do |page|
      page << "var container = $('#{container}');"
      page << "var element = $('#{dom_id}');"
      page << "element.remove();"
      page.insert_html :top, container, :partial => 'shared/runnable', :locals => {:runnable => @runnable}
    end  
  end
    
end
