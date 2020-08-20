class Admin::CohortsController < ApplicationController
  include RestrictedController
  before_filter :admin_only

  # GET /admin_cohorts
  def index
    @admin_cohorts = Admin::Cohort.search(params[:search], params[:page], nil)
    respond_to do |format|
      format.html # index.html.haml
      format.xml  { render :xml => @admin_cohorts }
    end
  end

  # GET /admin_cohorts/1
  # GET /admin_cohorts/1.xml
  def show
    @admin_cohort = Admin::Cohort.find(params[:id])
    respond_to do |format|
      format.html # show.html.haml
      format.xml  { render :xml => @admin_cohort }
    end
  end

  # GET /admin_cohorts/new
  def new
    @admin_cohort = Admin::Cohort.new
    # render new.html.haml
  end

  # GET /admin_cohorts/1/edit
  def edit
    @admin_cohort = Admin::Cohort.find(params[:id])
    # render edit.html.haml
  end

  # POST /admin_cohorts
  def create
    @admin_cohort = Admin::Cohort.new(params[:admin_cohort])
    if @admin_cohort.save
      redirect_to @admin_cohort, notice: 'Admin::Cohort was successfully created.'
    else
      render action: 'new'
    end
  end

  # PUT /admin_cohorts/1
  def update
    @admin_cohort = Admin::Cohort.find(params[:id])
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
