class Portal::SchoolsController < ApplicationController
  
  include RestrictedPortalController
  before_filter :admin_or_manager
  before_filter :states_and_provinces, :only => [:new, :edit, :create, :update]

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

  def states_and_provinces
    if APP_CONFIG[:states_and_provinces]
      @states_and_provinces = StatesAndProvinces::STATES_AND_PROVINCES.to_a.select { |s| APP_CONFIG[:states_and_provinces].any? { |i| i == s[0] } }
    else
      @states_and_provinces = StatesAndProvinces::STATES_AND_PROVINCES.to_a
    end
    @states_and_provinces.collect! {|i| i.reverse}
    @states_and_provinces.sort! { |a, b| a[1] <=> b[1] }
  end
  
  public
  
  # GET /portal_schools
  # GET /portal_schools.xml
  def index
    @portal_schools = Portal::School.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @portal_schools }
    end
  end

  # GET /portal_schools/1
  # GET /portal_schools/1.xml
  def show
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
    @portal_school = Portal::School.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @portal_school }
    end
  end

  # GET /portal_schools/1/edit
  def edit
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
    cancel = params[:commit] == "Cancel"
    use_installer = (params[:settings] && params[:settings][:use_installer] == "1")
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
        @portal_school.put_setting("use_installer", "1") if use_installer
        render :partial => 'show', :locals => { :portal_school => @portal_school }
      else
        render :xml => @portal_school.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @portal_school.save
          @portal_school.put_setting("use_installer", "1") if use_installer
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
    cancel = params[:commit] == "Cancel"
    use_installer = (params[:settings] && params[:settings][:use_installer] == "1")
    @portal_school = Portal::School.find(params[:id])
    if request.xhr?
      if cancel || @portal_school.update_attributes(params[:portal_school])
        unless cancel
          if use_installer
            @portal_school.put_setting("use_installer", "1")
          else
            if setting = @portal_school.get_setting("use_installer")
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
          if use_installer
            @portal_school.put_setting("use_installer", "1")
          else
            if setting = @portal_school.get_setting("use_installer")
              setting.destroy
              @portal_school.reload
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
    @portal_school = Portal::School.find(params[:id])
    @portal_school.destroy

    respond_to do |format|
      format.html { redirect_to(portal_schools_url) }
      format.js {} # will render destroy.rjs
      format.xml  { head :ok }
    end
  end
end
