class Portal::DistrictsController < ApplicationController

  include RestrictedPortalController
  # PUNDIT_CHECK_FILTERS
  before_action :admin_only

  public

  # GET /portal_districts
  # GET /portal_districts.xml
  def index
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::District
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (did not find instance)
    # @districts = policy_scope(Portal::District)
    @portal_districts = Portal::District.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @portal_districts }
    end
  end

  # GET /portal_districts/1
  # GET /portal_districts/1.xml
  def show
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @district
    @portal_district = Portal::District.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @portal_district }
    end
  end

  # GET /portal_districts/new
  # GET /portal_districts/new.xml
  def new
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::District
    @portal_district = Portal::District.new
    # renders new.html.haml
  end

  # GET /portal_districts/1/edit
  def edit
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @district
    @portal_district = Portal::District.find(params[:id])
  end

  # POST /portal_districts
  # POST /portal_districts.xml
  def create
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::District
    @portal_district = Portal::District.new(portal_district_strong_params(params[:portal_district]))
    cancel = params[:commit] == "Cancel"

    if @portal_district.save
      flash['notice'] = 'Portal::District was successfully created.'
      redirect_to @portal_district
    else
      render :action => "new"
    end
  end

  # PUT /portal_districts/1
  # PUT /portal_districts/1.xml
  def update
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @district
    cancel = params[:commit] == "Cancel"
    @portal_district = Portal::District.find(params[:id])

    if @portal_district.update(portal_district_strong_params(params[:portal_district]))
      flash['notice'] = 'Portal::District was successfully updated.'
      redirect_to @portal_district
    else
      render :action => "edit"
    end
  end

  # DELETE /portal_districts/1
  # DELETE /portal_districts/1.xml
  def destroy
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @district
    @portal_district = Portal::District.find(params[:id])
    @portal_district.destroy

    respond_to do |format|
      format.html { redirect_to(portal_districts_url) }
      format.js {}
      format.xml  { head :ok }
    end
  end

  def portal_district_strong_params(params)
    params && params.permit(:description, :leaid, :name, :nces_district_id, :state, :zipcode)
  end
end
