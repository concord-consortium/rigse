class Portal::Nces06DistrictsController < ApplicationController

  include RestrictedPortalController
  before_filter :admin_only
  public
  
  # GET /portal_nces06_districts
  # GET /portal_nces06_districts.xml
  def index
    @nces06_districts = Portal::Nces06District.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @nces06_districts }
    end
  end

  # GET /portal_nces06_districts/1
  # GET /portal_nces06_districts/1.xml
  def show
    @nces06_district = Portal::Nces06District.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @nces06_district }
    end
  end

  # GET /portal_nces06_districts/new
  # GET /portal_nces06_districts/new.xml
  def new
    @nces06_district = Portal::Nces06District.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @nces06_district }
    end
  end

  # GET /portal_nces06_districts/1/edit
  def edit
    @nces06_district = Portal::Nces06District.find(params[:id])
  end

  # POST /portal_nces06_districts
  # POST /portal_nces06_districts.xml
  def create
    @nces06_district = Portal::Nces06District.new(params[:nces06_district])

    respond_to do |format|
      if @nces06_district.save
        flash[:notice] = 'Portal::Nces06District was successfully created.'
        format.html { redirect_to(@nces06_district) }
        format.xml  { render :xml => @nces06_district, :status => :created, :location => @nces06_district }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @nces06_district.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /portal_nces06_districts/1
  # PUT /portal_nces06_districts/1.xml
  def update
    @nces06_district = Portal::Nces06District.find(params[:id])

    respond_to do |format|
      if @nces06_district.update_attributes(params[:nces06_district])
        flash[:notice] = 'Portal::Nces06District was successfully updated.'
        format.html { redirect_to(@nces06_district) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @nces06_district.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /portal_nces06_districts/1
  # DELETE /portal_nces06_districts/1.xml
  def destroy
    @nces06_district = Portal::Nces06District.find(params[:id])
    @nces06_district.destroy

    respond_to do |format|
      format.html { redirect_to(portal_nces06_districts_url) }
      format.xml  { head :ok }
    end
  end
end
