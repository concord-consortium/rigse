class DeviceConfigsController < ApplicationController
  # GET /device_configs
  # GET /device_configs.xml
  def index
    @device_configs = DeviceConfig.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @device_configs }
    end
  end

  # GET /device_configs/1
  # GET /device_configs/1.xml
  def show
    @device_config = DeviceConfig.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @device_config }
    end
  end

  # GET /device_configs/new
  # GET /device_configs/new.xml
  def new
    @device_config = DeviceConfig.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @device_config }
    end
  end

  # GET /device_configs/1/edit
  def edit
    @device_config = DeviceConfig.find(params[:id])
  end

  # POST /device_configs
  # POST /device_configs.xml
  def create
    @device_config = DeviceConfig.new(params[:device_config])

    respond_to do |format|
      if @device_config.save
        flash[:notice] = 'DeviceConfig was successfully created.'
        format.html { redirect_to(@device_config) }
        format.xml  { render :xml => @device_config, :status => :created, :location => @device_config }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @device_config.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /device_configs/1
  # PUT /device_configs/1.xml
  def update
    @device_config = DeviceConfig.find(params[:id])

    respond_to do |format|
      if @device_config.update_attributes(params[:device_config])
        flash[:notice] = 'DeviceConfig was successfully updated.'
        format.html { redirect_to(@device_config) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @device_config.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /device_configs/1
  # DELETE /device_configs/1.xml
  def destroy
    @device_config = DeviceConfig.find(params[:id])
    @device_config.destroy

    respond_to do |format|
      format.html { redirect_to(device_configs_url) }
      format.xml  { head :ok }
    end
  end
end
