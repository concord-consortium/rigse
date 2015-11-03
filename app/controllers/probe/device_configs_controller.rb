class Probe::DeviceConfigsController < ApplicationController
  # GET /Probe/device_configs
  # GET /Probe/device_configs.xml
  def index
    @device_configs = Probe::DeviceConfig.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @device_configs }
    end
  end

  # GET /Probe/device_configs/1
  # GET /Probe/device_configs/1.xml
  def show
    @device_config = Probe::DeviceConfig.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @device_config }
    end
  end

  # GET /Probe/device_configs/new
  # GET /Probe/device_configs/new.xml
  def new
    @device_config = Probe::DeviceConfig.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @device_config }
    end
  end

  # GET /Probe/device_configs/1/edit
  def edit
    @device_config = Probe::DeviceConfig.find(params[:id])
  end

  # POST /Probe/device_configs
  # POST /Probe/device_configs.xml
  def create
    @device_config = Probe::DeviceConfig.new(params[:device_config])

    respond_to do |format|
      if @device_config.save
        flash[:notice] = 'Probe::DeviceConfig.was successfully created.'
        format.html { redirect_to(@device_config) }
        format.xml  { render :xml => @device_config, :status => :created, :location => @device_config }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @device_config.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /Probe/device_configs/1
  # PUT /Probe/device_configs/1.xml
  def update
    @device_config = Probe::DeviceConfig.find(params[:id])

    respond_to do |format|
      if @device_config.update_attributes(params[:device_config])
        flash[:notice] = 'Probe::DeviceConfig.was successfully updated.'
        format.html { redirect_to(@device_config) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @device_config.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /Probe/device_configs/1
  # DELETE /Probe/device_configs/1.xml
  def destroy
    @device_config = Probe::DeviceConfig.find(params[:id])
    @device_config.destroy

    respond_to do |format|
      format.html { redirect_to(device_configs_url) }
      format.xml  { head :ok }
    end
  end
end
