class Sparks::ActivitiesController < ApplicationController
  
  before_filter :admin_only

  def index
    @activities = Sparks::Activity.all
  end
  
  def show
    @activity = Sparks::Activity.find(params[:id])
    respond_to do |format|
      format.html { render :layout => 'layouts/sparks/report' }
    end
  end
  
  def new
    @activity = Sparks::Activity.new
  end
  
  def edit
    @sparks_activity = Sparks::Activity.find(params[:id])
  end
  
  def create
    puts "params=#{params.inspect}"
    @activity = Sparks::Activity.new(params[:sparks_activity])
    if @activity.save
      flash[:notice] = 'Activity was successfully created.'
        redirect_to(@activity)
    else
      render :action => 'new'
    end
  end
  
  def update
    @activity = Sparks::Activity.find(params[:id])
    if @activity.update_attributes(params[:sparks_activity])
      flash[:notice] = 'Activity was successfully updated.'
      redirect_to(@activity)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @activity = Sparks::Activity.find(params[:id])
    @activity.destroy
    redirect_to(sparks_activities_url)
  end
  
  protected
  
  def admin_only
    unless current_user.has_role?('admin')
      flash[:notice] = 'Please log in as an administrator to access the page'
      redirect_to(:login)
    end
  end
  
end
