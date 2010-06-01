class Sparks::RubricsController < ApplicationController
  
  before_filter :admin_only, :except => :show

  def index
    @rubrics = Sparks::Rubric.all
  end
  
  def show
    @rubric = Sparks::Rubric.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render :json => @rubric.content }
    end
  end
  
  def new
    @rubric = Sparks::Rubric.new
  end
  
  def edit
    @rubric = Sparks::Rubric.find(params[:id])
  end
  
  def create
    puts "params=#{params.inspect}"
    @rubric = Sparks::Rubric.new(params[:sparks_rubric])
    if @rubric.save
      flash[:notice] = 'Rubric was successfully created.'
        redirect_to(@rubric)
    else
      render :action => 'new'
    end
  end
  
  def update
    @rubric = Sparks::Rubric.find(params[:id])
    if @rubric.update_attributes(params[:sparks_rubbric])
      flash[:notice] = 'Rubric was successfully updated.'
      redirect_to(@rubric)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @rubric = Sparks::Rubric.find(params[:id])
    @rubric.destroy
    redirect_to(sparks_rubrics_url)
  end
  
  def get_rubric
    puts ('*' * 72 + "\n") * 4
    puts "rubricId=#{params[:rubric_id]}"
    @rubric = Sparks::Rubric.find_by_rubric_id(params[:rubric_id])
    render :json => @rubric.content
  end
    
  protected  
  
  def admin_only
    unless current_user.has_role?('admin')
      flash[:notice] = 'Please log in as an administrator to access the page'
      redirect_to(:login)
    end
  end
  
end
