class CalibrationsController < ApplicationController
  # GET /calibrations
  # GET /calibrations.xml
  def index
    @calibrations = Calibration.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @calibrations }
    end
  end

  # GET /calibrations/1
  # GET /calibrations/1.xml
  def show
    @calibration = Calibration.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @calibration }
    end
  end

  # GET /calibrations/new
  # GET /calibrations/new.xml
  def new
    @calibration = Calibration.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @calibration }
    end
  end

  # GET /calibrations/1/edit
  def edit
    @calibration = Calibration.find(params[:id])
  end

  # POST /calibrations
  # POST /calibrations.xml
  def create
    @calibration = Calibration.new(params[:calibration])

    respond_to do |format|
      if @calibration.save
        flash[:notice] = 'Calibration was successfully created.'
        format.html { redirect_to(@calibration) }
        format.xml  { render :xml => @calibration, :status => :created, :location => @calibration }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @calibration.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /calibrations/1
  # PUT /calibrations/1.xml
  def update
    @calibration = Calibration.find(params[:id])

    respond_to do |format|
      if @calibration.update_attributes(params[:calibration])
        flash[:notice] = 'Calibration was successfully updated.'
        format.html { redirect_to(@calibration) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @calibration.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /calibrations/1
  # DELETE /calibrations/1.xml
  def destroy
    @calibration = Calibration.find(params[:id])
    @calibration.destroy

    respond_to do |format|
      format.html { redirect_to(calibrations_url) }
      format.xml  { head :ok }
    end
  end
end
