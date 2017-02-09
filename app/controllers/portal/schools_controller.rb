class Portal::SchoolsController < ApplicationController

  include RestrictedPortalController
  # PUNDIT_CHECK_FILTERS
  before_filter :admin_or_manager
  before_filter :states_and_provinces, :only => [:new, :edit, :create, :update]

  protected

  def admin_only
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
  end

  public

  # GET /portal_schools
  # GET /portal_schools.xml
  def index
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::School
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (did not find instance)
    # @schools = policy_scope(Portal::School)
    @portal_schools = Portal::School.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @portal_schools }
    end
  end

  # GET /portal_schools/1
  # GET /portal_schools/1.xml
  def show
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @school
    @portal_school = Portal::School.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :portal_school => @portal_school, :is_edit => true }
    else
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @portal_school }
      end
    end
  end

  # GET /portal_schools/new
  # GET /portal_schools/new.xml
  def new
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::School
    @portal_school = Portal::School.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @portal_school }
    end
  end

  # GET /portal_schools/1/edit
  def edit
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @school
    @portal_school = Portal::School.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :portal_school => @portal_school, :is_edit => true }
    else
      respond_to do |format|
        format.html
        format.xml  { render :xml => @portal_school }
      end
    end
  end

  # POST /portal_schools
  # POST /portal_schools.xml
  def create
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::School
    cancel = params[:commit] == "Cancel"
    change_skip_installer = (params[:settings] && params[:settings][:skip_installer])
    skip_installer = (params[:settings][:skip_installer] == "1") if change_skip_installer
    if params[:nces_school]
      @nces_school = Portal::Nces06School.find(params[:nces_school][:id])
      @portal_school = Portal::School.find_or_create_by_nces_school(@nces_school) if @nces_school
    else
      @portal_school = Portal::School.new(params[:portal_school])
    end
    if request.xhr?
      if cancel
        redirect_to :index
      elsif @portal_school.save
        @portal_school.put_setting("skip_installer", "1") if skip_installer && change_skip_installer
        render :partial => 'show', :locals => { :portal_school => @portal_school }
      else
        render :xml => @portal_school.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @portal_school.save
          @portal_school.put_setting("skip_installer", "1") if skip_installer && change_skip_installer
          flash[:notice] = 'Portal::School was successfully created.'
          format.html { redirect_to(@portal_school) }
          format.xml  { render :xml => @portal_school, :status => :created, :location => @portal_school }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @portal_school.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /portal_schools/1
  # PUT /portal_schools/1.xml
  def update
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @school
    cancel = params[:commit] == "Cancel"
    change_skip_installer = (params[:settings] && params[:settings][:skip_installer])
    skip_installer = (params[:settings][:skip_installer] == "1") if change_skip_installer
    @portal_school = Portal::School.find(params[:id])
    if request.xhr?
      if cancel || @portal_school.update_attributes(params[:portal_school])
        unless cancel || !change_skip_installer
          if skip_installer
            @portal_school.put_setting("skip_installer", "1")
          else
            if setting = @portal_school.get_setting("skip_installer")
              setting.destroy
              @portal_school.reload
            end
          end
        end
        render :partial => 'show', :locals => { :portal_school => @portal_school }
      else
        render :xml => @portal_school.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @portal_school.update_attributes(params[:portal_school])
          if change_skip_installer
            if skip_installer
              @portal_school.put_setting("skip_installer", "1")
            else
              if setting = @portal_school.get_setting("skip_installer")
                setting.destroy
                @portal_school.reload
              end
            end
          end
          flash[:notice] = 'Portal::School was successfully updated.'
          format.html { redirect_to(@portal_school) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @portal_school.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /portal_schools/1
  # DELETE /portal_schools/1.xml
  def destroy
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @school
    @portal_school = Portal::School.find(params[:id])
    @portal_school.destroy

    respond_to do |format|
      format.html { redirect_to(portal_schools_url) }
      format.js {} # will render destroy.rjs
      format.xml  { head :ok }
    end
  end
end
