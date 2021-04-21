class Admin::CohortsController < ApplicationController
  include RestrictedController

  before_action :check_for_project

  # Note that we have to assign @projects even for create and update
  # because they might render the edit or new templates (on validation error)
  before_action :get_scoped_projects, only: ['new', 'edit', 'create', 'update']
  before_action :find_cohort, only: ['show', 'edit', 'update', 'destroy']

  private

  def check_for_project
    return unless params[:project_id]

    @project = Admin::Project.find(params[:project_id])
    authorize @project
  end

  def get_scoped_projects
    @projects = policy_scope(Admin::Project)
    @projects = @projects.where(id: @project.id) if @project
  end

  def find_cohort
    @admin_cohort = Admin::Cohort.find(params[:id])
  end

  public

  def check_for_project
    return unless params[:project_id]

    @project = Admin::Project.find(params[:project_id])
    authorize @project
  end

  # GET /admin_cohorts
  def index
    authorize Admin::Cohort
    search_scope = policy_scope(Admin::Cohort)
    search_scope = search_scope.where(project_id: @project.id) if @project
    @admin_cohorts = Admin::Cohort.search(params[:search], params[:page], nil, nil, search_scope)
    # render index.html.haml
  end

  # GET /admin_cohorts/1
  def show
    authorize @admin_cohort
    # render show.html.haml
  end

  # GET /admin_cohorts/new
  def new
    authorize Admin::Cohort
    @admin_cohort = Admin::Cohort.new
    @admin_cohort.project_id = @project.id if @project
    # render new.html.haml
  end

  # GET /admin_cohorts/1/edit
  def edit
    authorize Admin::Cohort
    # render edit.html.haml
  end

  # POST /admin_cohorts
  def create
    @admin_cohort = Admin::Cohort.new(admin_cohort_strong_params(params[:admin_cohort]))
    authorize @admin_cohort
    if @admin_cohort.save
      redirect_to @admin_cohort, notice: 'Admin::Cohort was successfully created.'
    else
      render action: 'new'
    end
  end

  # PUT /admin_cohorts/1
  def update
    authorize @admin_cohort
    if @admin_cohort.update_attributes(admin_cohort_strong_params(params[:admin_cohort]))
      redirect_to @admin_cohort, notice: 'Admin::Cohort was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /admin_cohorts/1
  def destroy
    authorize @admin_cohort
    @admin_cohort.destroy
    flash['notice'] = "Cohort #{@admin_cohort.name} was deleted"
    redirect_back_or admin_cohorts_url
  end

  def admin_cohort_strong_params(params)
    params && params.permit(:email_notifications_enabled, :items, :name, :project, :project_id)
  end
end
