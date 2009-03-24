class ActivityStepsController < ApplicationController
  # GET /activity_steps
  # GET /activity_steps.xml
  def index
    @activity_steps = ActivitySteps.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @activity_steps }
    end
  end

  # GET /activity_steps/1
  # GET /activity_steps/1.xml
  def show
    @activity_steps = ActivitySteps.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @activity_steps }
    end
  end

  # GET /activity_steps/new
  # GET /activity_steps/new.xml
  def new
    @activity_steps = ActivitySteps.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @activity_steps }
    end
  end

  # GET /activity_steps/1/edit
  def edit
    @activity_steps = ActivitySteps.find(params[:id])
  end

  # POST /activity_steps
  # POST /activity_steps.xml
  def create
    @activity_steps = ActivitySteps.new(params[:activity_steps])

    respond_to do |format|
      if @activity_steps.save
        flash[:notice] = 'ActivitySteps was successfully created.'
        format.html { redirect_to(@activity_steps) }
        format.xml  { render :xml => @activity_steps, :status => :created, :location => @activity_steps }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @activity_steps.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /activity_steps/1
  # PUT /activity_steps/1.xml
  def update
    @activity_steps = ActivitySteps.find(params[:id])

    respond_to do |format|
      if @activity_steps.update_attributes(params[:activity_steps])
        flash[:notice] = 'ActivitySteps was successfully updated.'
        format.html { redirect_to(@activity_steps) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @activity_steps.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /activity_steps/1
  # DELETE /activity_steps/1.xml
  def destroy
    @activity_steps = ActivitySteps.find(params[:id])
    @activity_steps.destroy

    respond_to do |format|
      format.html { redirect_to(activity_steps_url) }
      format.xml  { head :ok }
    end
  end
end
