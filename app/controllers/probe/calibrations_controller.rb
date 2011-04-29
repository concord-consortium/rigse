class Probe::CalibrationsController < ApplicationController
  # GET /Probe/calibrations
  # GET /Probe/calibrations.xml
  def index
    @calibrations = Probe::Calibration.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @calibrations }
    end
  end

  # GET /Probe/calibrations/1
  # GET /Probe/calibrations/1.xml
  def show
    @calibration = Probe::Calibration.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @calibration }
    end
  end

  # GET /Probe/calibrations/new
  # GET /Probe/calibrations/new.xml
  def new
    @calibration = Probe::Calibration.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @calibration }
    end
  end

  # GET /Probe/calibrations/1/edit
  def edit
    @calibration = Probe::Calibration.find(params[:id])
  end

  # POST /Probe/calibrations
  # POST /Probe/calibrations.xml
  def create
    @calibration = Probe::Calibration.new(params[:calibration])

    respond_to do |format|
      if @calibration.save
        flash[:notice] = 'Probe::Calibration.was successfully created.'
        format.html { redirect_to(@calibration) }
        format.xml  { render :xml => @calibration, :status => :created, :location => @calibration }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @calibration.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /Probe/calibrations/1
  # PUT /Probe/calibrations/1.xml
  def update
    @calibration = Probe::Calibration.find(params[:id])

    respond_to do |format|
      if @calibration.update_attributes(params[:calibration])
        flash[:notice] = 'Probe::Calibration.was successfully updated.'
        format.html { redirect_to(@calibration) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @calibration.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /Probe/calibrations/1
  # DELETE /Probe/calibrations/1.xml
  def destroy
    @calibration = Probe::Calibration.find(params[:id])
    @calibration.destroy

    respond_to do |format|
      format.html { redirect_to(calibrations_url) }
      format.xml  { head :ok }
    end
  end
end
