class Admin::CohortsController < ApplicationController
  include RestrictedController

  # GET /admin_cohorts
  def index
    authorize Admin::Cohort

    @admin_cohorts = Admin::Cohort.search(params[:search], params[:page], nil, nil, policy_scope(Admin::Cohort))
    # render index.html.haml
  end

  # GET /admin_cohorts/1
  def show
    @admin_cohort = Admin::Cohort.find(params[:id])
    authorize @admin_cohort
    # render show.html.haml
  end

  # GET /admin_cohorts/new
  def new
    authorize Admin::Cohort
    @admin_cohort = Admin::Cohort.new
    @projects = policy_scope(Admin::Project)
    # render new.html.haml
  end

  # GET /admin_cohorts/1/edit
  def edit
    authorize Admin::Cohort
    @admin_cohort = Admin::Cohort.find(params[:id])
    @projects = policy_scope(Admin::Project)
    # render edit.html.haml
  end

  # POST /admin_cohorts
  def create
    @admin_cohort = Admin::Cohort.new(params[:admin_cohort])
    authorize @admin_cohort
    if @admin_cohort.save
      redirect_to @admin_cohort, notice: 'Admin::Cohort was successfully created.'
    else
      render action: 'new'
    end
  end

  # PUT /admin_cohorts/1
  def update
    @admin_cohort = Admin::Cohort.find(params[:id])
    authorize @admin_cohort
    if @admin_cohort.update_attributes(params[:admin_cohort])
      redirect_to @admin_cohort, notice: 'Admin::Cohort was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /admin_cohorts/1
  def destroy
    @admin_cohort = Admin::Cohort.find(params[:id])
    @admin_cohort.destroy
    redirect_to admin_cohorts_url, notice: "Tag #{@admin_cohort.name} was deleted"
  end
end
