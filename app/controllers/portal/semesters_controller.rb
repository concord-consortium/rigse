class Portal::SemestersController < ApplicationController
  
  include RestrictedPortalController
  public
  
  # GET /portal_semesters
  # GET /portal_semesters.xml
  def index
    @semesters = Portal::Semester.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @semesters }
    end
  end

  # GET /portal_semesters/1
  # GET /portal_semesters/1.xml
  def show
    @semester = Portal::Semester.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @semester }
    end
  end

  # GET /portal_semesters/new
  # GET /portal_semesters/new.xml
  def new
    @semester = Portal::Semester.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @semester }
    end
  end

  # GET /portal_semesters/1/edit
  def edit
    @semester = Portal::Semester.find(params[:id])
  end

  # POST /portal_semesters
  # POST /portal_semesters.xml
  def create
    @semester = Portal::Semester.new(params[:portal_semester])

    respond_to do |format|
      if @semester.save
        flash[:notice] = 'Portal::Semester was successfully created.'
        format.html { redirect_to(@semester) }
        format.xml  { render :xml => @semester, :status => :created, :location => @semester }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @semester.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /portal_semesters/1
  # PUT /portal_semesters/1.xml
  def update
    @semester = Portal::Semester.find(params[:id])
    respond_to do |format|
      if @semester.update_attributes(params[:portal_semester])
        flash[:notice] = 'Portal::Semester was successfully updated.'
        format.html { redirect_to(@semester) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @semester.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /portal_semesters/1
  # DELETE /portal_semesters/1.xml
  def destroy
    @semester = Portal::Semester.find(params[:id])
    @semester.destroy

    respond_to do |format|
      format.html { redirect_to(portal_semesters_url) }
      format.xml  { head :ok }
    end
  end
end
