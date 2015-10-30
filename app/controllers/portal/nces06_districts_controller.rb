class Portal::Nces06DistrictsController < ApplicationController

  # PUNDIT_CHECK_FILTERS
  before_filter :admin_or_manager, :except => [ :index ]
  include RestrictedPortalController

  protected

  def admin_only
    unless current_visitor.has_role?('admin')
      flash[:notice] = "Please log in as an administrator" 
      redirect_to(:home)
    end
  end
  
  def admin_or_manager
    if current_visitor.has_role?('admin')
      @admin_role = true
    elsif current_visitor.has_role?('manager')
      @manager_role = true
    else
      flash[:notice] = "Please log in as an administrator or manager" 
      redirect_to(:home)
    end
  end

  public
  
  # GET /portal_nces06_districts
  # GET /portal_nces06_districts.xml
  def index
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::Nces06District
    select = "id, NAME"
    if params[:state_or_province]
      @nces06_districts = Portal::Nces06District.find(:all, :conditions => ["MSTATE = ?", params[:state_or_province]], :select => select, :order => 'NAME')
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (found instance)
    # @nces06_districts = policy_scope(Portal::Nces06District)
    else
      @nces06_districts = Portal::Nces06District.find(:all, :select => select, :order => 'NAME')
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml  => @nces06_districts }
      format.json { render :json => @nces06_districts }
    end
  end

  # GET /portal_nces06_districts/1
  # GET /portal_nces06_districts/1.xml
  def show
    @nces06_district = Portal::Nces06District.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @nces06_district

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @nces06_district }
    end
  end

  # GET /portal_nces06_districts/new
  # GET /portal_nces06_districts/new.xml
  def new
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::Nces06District
    @nces06_district = Portal::Nces06District.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @nces06_district }
    end
  end

  # GET /portal_nces06_districts/1/edit
  def edit
    @nces06_district = Portal::Nces06District.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @nces06_district
  end

  # POST /portal_nces06_districts
  # POST /portal_nces06_districts.xml
  def create
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::Nces06District
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
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @nces06_district

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
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @nces06_district
    @nces06_district.destroy

    respond_to do |format|
      format.html { redirect_to(portal_nces06_districts_url) }
      format.xml  { head :ok }
    end
  end
end
