class Admin::SettingsController < ApplicationController

  # PUNDIT_CHECK_FILTERS
  before_filter :admin_only, :except => [:index, :edit, :update]
  before_filter :admin_or_manager, :only => [:index, :edit, :update]
  # before_filter :setup_object, :except => [:index]
  # before_filter :render_scope, :only => [:show]

  # editing / modifying / deleting require editable-ness
  # before_filter :can_edit, :except => [:index,:show,:print,:create,:new,:duplicate,:export]
  # before_filter :can_create, :only => [:new, :create,:duplicate]
  #
  # in_place_edit_for :activity, :name
  # in_place_edit_for :activity, :description

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

  public

  # GET /admin/settings
  # GET /admin/settings.xml
  def index
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Admin::Setting
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (did not find instance)
    # @settings = policy_scope(Admin::Setting)
    default_settings = Admin::Settings.default_settings

    if @manager_role
      @admin_settings = [default_settings].paginate
    else
      # convert from ActiveRecord::Relation to a collection
      # because delete bellow will remove from db otherwise
      @admin_settings = Admin::Settings.search(params[:search], params[:page], nil).to_a
    end

    # If default_settings is in collection to be displayed then put it first.
    unless @admin_settings.length <= 1 || @admin_settings[0].default_settings?
      if @admin_settings.delete(default_settings)
        @admin_settings.unshift(default_settings)
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @admin_settings }
    end
  end

  # GET /admin/settings/1
  # GET /admin/settings/1.xml
  def show
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @setting
    @admin_settings = Admin::Settings.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @admin_settings }
    end
  end

  # GET /admin/settings/new
  # GET /admin/settings/new.xml
  def new
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Admin::Setting
    @admin_settings = Admin::Settings.new
    @scope = nil


    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @admin_settings }
    end
  end

  # GET /admin/settings/1/edit
  def edit
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @setting
    @admin_settings = Admin::Settings.find(params[:id])

    # Pull in the current theme default home page content, if it isn't set in the settings.
    if @admin_settings.home_page_content.nil? || @admin_settings.home_page_content.empty?
      render_to_string :partial => "home/project_info"

      @admin_settings.home_page_content = view_context.instance_variable_get(:@content_for_project_info)
      view_context.instance_variable_set(:@content_for_project_info, nil)
    end

    if request.xhr?
      render :partial => 'remote_form', :locals => { :admin_settings => @admin_settings }
    end
  end

  # POST /admin/settings
  # POST /admin/settings.xml
  def create
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Admin::Setting
    @admin_settings = Admin::Settings.new(params[:admin_settings])
    respond_to do |format|
      if @admin_settings.save
        flash[:notice] = 'Admin::Settings was successfully created.'
        format.html { redirect_to(@admin_settings) }
        format.xml  { render :xml => @admin_settings, :status => :created, :location => @admin_settings }
      else
        format.html { redirect_to(new_admin_setting_url) }
        format.xml  { render :xml => @admin_settings.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/settings/1
  # PUT /admin/settings/1.xml
  def update
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @setting
    @admin_settings = Admin::Settings.find(params[:id])
    if request.xhr?
      @admin_settings.update_attributes(params[:admin_settings])
      render :partial => 'show', :locals => { :admin_settings => @admin_settings }
    else
      respond_to do |format|
        if @admin_settings.update_attributes(params[:admin_settings])
          flash[:notice] = 'Admin::Settings was successfully updated.'
          format.html { redirect_to(@admin_settings) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @admin_settings.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /admin/settings/1
  # DELETE /admin/settings/1.xml
  def destroy
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @setting
    @settings = Admin::Settings.find(params[:id])
    @settings.destroy

    respond_to do |format|
      format.html { redirect_to(admin_settings_url) }
      format.xml  { head :ok }
    end
  end

end
