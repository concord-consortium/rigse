class Admin::SettingsController < ApplicationController

  # PUNDIT_CHECK_FILTERS
  before_filter :admin_only, :except => [:index, :edit, :update]
  before_filter :admin_or_manager, :only => [:index, :edit, :update]
  # before_filter :setup_object, :except => [:index]
  # before_filter :render_scope, :only => [:show]

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
  def new
    @admin_settings = Admin::Settings.new
    # renders new.html.haml
  end

  # GET /admin/settings/1/edit
  def edit
    @admin_settings = Admin::Settings.find(params[:id])
    # renders edit.html.haml
  end

  # POST /admin/settings
  def create
    @admin_settings = Admin::Settings.new(admin_settings_strong_params(params[:admin_settings]))
    if @admin_settings.save
      flash['notice'] = 'Admin::Settings was successfully created.'
      redirect_to @admin_settings
    else
      render action: 'new'
    end
  end

  # PUT /admin/settings/1
  def update
    @admin_settings = Admin::Settings.find(params[:id])
    if @admin_settings.update_attributes(admin_settings_strong_params(params[:admin_settings]))
      flash['notice'] = 'Admin::Settings was successfully updated.'
      redirect_to @admin_settings
    else
      render action: 'edit'
    end
  end

  # DELETE /admin/settings/1
  def destroy
    @settings = Admin::Settings.find(params[:id])
    @settings.destroy
    flash['notice'] = 'Settings successfully deleted.'
    redirect_to admin_settings_url
  end

  def admin_settings_strong_params(params)
    params && params.permit(:about_page_content, :active, :allow_adhoc_schools, :allow_default_class, :anonymous_can_browse_materials,
                            :auto_set_teachers_as_authors, :custom_help_page_html, :custom_search_path, :default_cohort_id, :description,
                            :enable_grade_levels, :enable_member_registration, :enabled_bookmark_types, :external_url, :help_type,
                            :home_page_content, :include_external_activities, :jnlp_cdn_hostname, :jnlp_url, :pub_interval,
                            :require_user_consent, :show_collections_menu, :teacher_home_path, :teachers_can_author, :use_bitmap_snapshots,
                            :use_periodic_bundle_uploading, :use_student_security_questions, :user_id, :wrap_home_page_content)
  end
end
