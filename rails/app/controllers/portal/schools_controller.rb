class Portal::SchoolsController < ApplicationController

  include RestrictedPortalController
  # PUNDIT_CHECK_FILTERS
  before_action :admin_or_manager
  before_action :states_and_provinces, :only => [:new, :edit, :create, :update]

  protected

  def admin_only
    # PUNDIT_CHECK_AUTHORIZE
    # PUNDIT_CHECK_SCOPE (did not find instance)
    # @schools = policy_scope(Portal::School)
    unless current_visitor.has_role?('admin')
      raise Pundit::NotAuthorizedError
    end
  end

  def admin_or_manager
    if current_visitor.has_role?('admin')
      @admin_role = true
    elsif current_visitor.has_role?('manager')
      @manager_role = true
    else
      raise Pundit::NotAuthorizedError
    end
  end

  def states_and_provinces
    @states_and_provinces = Portal::StateOrProvince.from_districts.sort
    @districts = Portal::District.order(:name).map { |d| [ d.name, d.id ] }
  end

  public

  # GET /portal_schools
  # GET /portal_schools.xml
  def index
    @portal_schools = Portal::School.search(params[:search], params[:page], nil)
    respond_to do |format|
      format.html # app/views/portal/schools/index.html.haml
      format.xml  { render xml: @portal_schools }
    end
  end

  # GET /portal_schools/1
  # GET /portal_schools/1.xml
  def show
    @portal_school = Portal::School.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @portal_school }
    end
  end

  # GET /portal_schools/new
  # renders new.html.haml
  def new
    @portal_school = Portal::School.new
  end

  # GET /portal_schools/1/edit
  # renders edit.html.haml
  def edit
    @portal_school = Portal::School.find(params[:id])
  end

  # POST /portal_schools
  def create
    if params[:nces_school]
      @nces_school = Portal::Nces06School.find(params[:nces_school][:id])
      @portal_school = Portal::School.find_or_create_using_nces_school(@nces_school) if @nces_school
    else
      @portal_school = Portal::School.new(portal_school_strong_params(params[:portal_school]))
    end

    if @portal_school.save
      flash['notice'] = 'Portal::School was successfully created.'
      redirect_to @portal_school
    else
      render :action => 'new'
    end
  end

  # PUT /portal_schools/1
  # PUT /portal_schools/1.xml
  def update
    cancel = params[:commit] == 'Cancel'
    @portal_school = Portal::School.find(params[:id])
    if @portal_school.update_attributes(portal_school_strong_params(params[:portal_school]))
      flash['notice'] = 'Portal::School was successfully updated.'
      redirect_to action: :index
    else
      render :action => 'edit'
    end
  end

  # DELETE /portal_schools/1
  # DELETE /portal_schools/1.xml
  def destroy
    @portal_school = Portal::School.find(params[:id])
    @portal_school.destroy
    redirect_to action: :index
  end

  def portal_school_strong_params(params)
    params && params.permit(:city, :country_id, :description, :district_id, :name, :nces_school_id, :ncessch, :state, :zipcode)
  end
end
