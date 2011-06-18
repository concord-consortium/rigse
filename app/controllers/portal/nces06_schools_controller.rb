class Portal::Nces06SchoolsController < ApplicationController
  
  before_filter :admin_or_manager, :except => [ :description, :index ]
  include RestrictedPortalController

  protected

  def admin_only
    unless current_user.has_role?('admin')
      flash[:notice] = "Please log in as an administrator" 
      redirect_to(:home)
    end
  end
  
  def admin_or_manager
    if current_user.has_role?('admin')
      @admin_role = true
    elsif current_user.has_role?('manager')
      @manager_role = true
    else
      flash[:notice] = "Please log in as an administrator or manager" 
      redirect_to(:home)
    end
  end

  public
  
  # GET /portal_nces06_schools
  # GET /portal_nces06_schools.xml
  def index
    select = "id, SCHNAM"
    if params[:state_or_province]
      @nces06_schools = Portal::Nces06School.find(:all, :conditions => ["MSTATE = ?", params[:state_or_province]], :select => select, :order => 'SCHNAM')
    elsif params[:nces_district_id]
      @nces06_schools = Portal::Nces06School.find(:all, :conditions => ["nces_district_id = ?", params[:nces_district_id]], :select => select, :order => 'SCHNAM')
    else
      @nces06_schools = Portal::Nces06School.find(:all, :select => select, :order => 'SCHNAM')
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @nces06_schools }
      format.json { render :json => @nces06_schools }
    end
  end

  # GET /portal_nces06_schools/1
  # GET /portal_nces06_schools/1.xml
  def show
    @nces06_school = Portal::Nces06School.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @nces06_school }
    end
  end

  # GET /portal_nces06_schools/new
  # GET /portal_nces06_schools/new.xml
  def new
    @nces06_school = Portal::Nces06School.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @nces06_school }
    end
  end

  # GET /portal_nces06_schools/1/edit
  def edit
    @nces06_school = Portal::Nces06School.find(params[:id])
  end

  # POST /portal_nces06_schools
  # POST /portal_nces06_schools.xml
  def create
    @nces06_school = Portal::Nces06School.new(params[:nces06_school])

    respond_to do |format|
      if @nces06_school.save
        flash[:notice] = 'Portal::Nces06School was successfully created.'
        format.html { redirect_to(@nces06_school) }
        format.xml  { render :xml => @nces06_school, :status => :created, :location => @nces06_school }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @nces06_school.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /portal_nces06_schools/1
  # PUT /portal_nces06_schools/1.xml
  def update
    @nces06_school = Portal::Nces06School.find(params[:id])

    respond_to do |format|
      if @nces06_school.update_attributes(params[:nces06_school])
        flash[:notice] = 'Portal::Nces06School was successfully updated.'
        format.html { redirect_to(@nces06_school) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @nces06_school.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /portal_nces06_schools/1
  # DELETE /portal_nces06_schools/1.xml
  def destroy
    @nces06_school = Portal::Nces06School.find(params[:id])
    @nces06_school.destroy

    respond_to do |format|
      format.html { redirect_to(portal_nces06_schools_url) }
      format.xml  { head :ok }
    end
  end
  
  def description
    @nces06_school = Portal::Nces06School.find(params[:id])
    respond_to do |format|
      format.json { render :json => @nces06_school.summary.to_json, :layout => false }
    end
  end
end
