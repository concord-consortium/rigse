class Portal::DistrictsController < ApplicationController
  
  include RestrictedPortalController
  # PUNDIT_CHECK_FILTERS
  before_filter :admin_only
  
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

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @portal_district }
    end
  end

  # GET /portal_districts/1/edit
  def edit
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @district
    @portal_district = Portal::District.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :portal_district => @portal_district }
    else
      respond_to do |format|
        format.html
        format.xml  { render :xml => @portal_district }
      end
    end
  end

  # POST /portal_districts
  # POST /portal_districts.xml
  def create
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::District
    @portal_district = Portal::District.new(params[:portal_district])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @portal_district.save
        render :partial => 'new', :locals => { :portal_district => @portal_district }
      else
        render :xml => @portal_district.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @portal_district.save
          flash[:notice] = 'Portal::District was successfully created.'
          format.html { redirect_to(@portal_district) }
          format.xml  { render :xml => @portal_district, :status => :created, :location => @portal_district }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @portal_district.errors, :status => :unprocessable_entity }
        end
      end
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
    if request.xhr?
      if cancel || @portal_district.update_attributes(params[:portal_district])
        render :partial => 'show', :locals => { :portal_district => @portal_district }
      else
        render :xml => @portal_district.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @portal_district.update_attributes(params[:portal_district])
          flash[:notice] = 'Portal::District was successfully updated.'
          format.html { redirect_to(@portal_district) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @portal_district.errors, :status => :unprocessable_entity }
        end
      end
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
end
