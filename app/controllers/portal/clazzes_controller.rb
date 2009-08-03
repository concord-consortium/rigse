class Portal::ClazzesController < ApplicationController
  # GET /portal_clazzes
  # GET /portal_clazzes.xml
  def index
    @clazzes = Portal::Clazz.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @clazzes }
    end
  end

  # GET /portal_clazzes/1
  # GET /portal_clazzes/1.xml
  def show
    @clazz = Portal::Clazz.find(params[:id])
    @teacher = @clazz.parent
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @clazz }
    end
  end

  # GET /portal_clazzes/new
  # GET /portal_clazzes/new.xml
  def new
    @semesters = Portal::Semester.find(:all)
    @clazz = Portal::Clazz.new
    if params[:teacher_id]
      @clazz.teacher = Portal::Teacher.find(params[:teacher_id])
    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @clazz }
    end
  end

  # GET /portal_clazzes/1/edit
  def edit
    @clazz = Portal::Clazz.find(params[:id])
    @semesters = Portal::Semester.find(:all)
  end

  # POST /portal_clazzes
  # POST /portal_clazzes.xml
  def create
    @clazz = Portal::Clazz.new(params[:portal_clazz])
    @semesters = Portal::Semester.find(:all)
    respond_to do |format|
      if @clazz.save
        flash[:notice] = 'Portal::Clazz was successfully created.'
        format.html { redirect_to(@clazz) }
        format.xml  { render :xml => @clazz, :status => :created, :location => @clazz }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @clazz.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /portal_clazzes/1
  # PUT /portal_clazzes/1.xml
  def update
    @clazz = Portal::Clazz.find(params[:id])
    respond_to do |format|
      if @clazz.update_attributes(params[:portal_clazz])
        flash[:notice] = 'Portal::Clazz was successfully updated.'
        format.html { redirect_to(@clazz) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @clazz.errors, :status => :unprocessable_entity }
      end
    end
  end  

  # DELETE /portal_clazzes/1
  # DELETE /portal_clazzes/1.xml
  def destroy
    @clazz = Portal::Clazz.find(params[:id])
    @clazz.destroy

    respond_to do |format|
      format.html { redirect_to(portal_clazzes_url) }
      format.xml  { head :ok }
    end
  end
  
  ## END OF CRUD METHODS
  def edit_offerings
    @clazz = Portal::Clazz.find(params[:id])
  end
  
  # HACK:
  # TODO: (IMPORTANT:) This  method is currenlty only for ajax requests, and uses dom_ids 
  # TODO: to infer runnables. Rewrite this, so that the params are less JS/DOM specific..
  def add_offering
    @clazz = Portal::Clazz.find(params[:id])
    dom_id = params[:dragged_dom_id]
    container = params[:dropped_dom_id]
    runnable_id = params[:runnable_id]
    runnable_type = params[:runnable_type].classify
    @offering = Portal::Offering.find_or_create_by_clazz_id_and_runnable_type_and_runnable_id(@clazz.id,runnable_type,runnable_id)
    if @offering
      @offering.save
      @clazz.reload
    end
    render :update do |page|
      page << "var element = $('#{dom_id}');"
      page << "element.remove();"
      page.insert_html :top, container, :partial => 'shared/offering_for_teacher', :locals => {:offering => @offering}
    end
  end
  
  # HACK:
  # TODO: (IMPORTANT:) This  method is currenlty only for ajax requests, and uses dom_ids 
  # TODO: to infer runnables. Rewrite this, so that the params are less JS/DOM specific..
  def remove_offering
    @clazz = Portal::Clazz.find(params[:id])
    dom_id = params[:dragged_dom_id]
    container = params[:dropped_dom_id]
    offering_id = params[:offering_id]
    @offering = Portal::Offering.find(offering_id)
    if @offering
      @runnable = @offering.runnable
      @offering.destroy
      @clazz.reload
    end
    render :update do |page|
      page << "var container = $('#{container}');"
      page << "var element = $('#{dom_id}');"
      page << "element.remove();"
      page.insert_html :top, container, :partial => 'shared/runnable', :locals => {:runnable => @runnable}
    end  
  end
    
end
