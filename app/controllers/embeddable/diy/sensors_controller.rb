class Embeddable::Diy::SensorsController < ApplicationController
  # GET /Embeddable/sensors
  # GET /Embeddable/sensors.xml
  def index
    @diy_sensors = Embeddable::Diy::Sensor.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @diy_sensors }
    end
  end

  # GET /Embeddable/sensors/1
  # GET /Embeddable/sensors/1.xml
  def show
    @diy_sensor = Embeddable::Diy::Sensor.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :diy_sensor => @diy_sensor }
    else
      respond_to do |format|
        format.html # show.html.erb
        format.otml { render :layout => "layouts/embeddable/sensor" } # sensor.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @diy_sensor , :teacher_mode => false } }
        format.config { render :partial => 'shared/show', :locals => { :runnable => @diy_sensor, :session_id => (params[:session] || request.env["rack.session.options"][:id]) , :teacher_mode => false } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @diy_sensor, :teacher_mode => @teacher_mode} }
        format.xml  { render :xml => @diy_sensor }
      end
    end
  end

  # GET /Embeddable/sensors/1/print
  def print
    @diy_sensor = Embeddable::Diy::Sensor.find(params[:id])
    respond_to do |format|
      format.html { render :layout => "layouts/embeddable/print" }
      format.xml  { render :xml => @diy_sensor }
    end
  end

  # GET /Embeddable/sensors/new
  # GET /Embeddable/sensors/new.xml
  def new
    @diy_sensor = Embeddable::Diy::Sensor.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :diy_sensor => @diy_sensor }
    else
      respond_to do |format|
        format.html
        format.xml  { render :xml => @diy_sensor }
      end
    end
  end

  # GET /Embeddable/sensors/1/edit
  def edit
    @diy_sensor = Embeddable::Diy::Sensor.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :diy_sensor => @diy_sensor }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @diy_sensor }
      end
    end
  end

  # POST /Embeddable/sensors
  # POST /Embeddable/sensors.xml
  def create
    @diy_sensor = Embeddable::Diy::Sensor.new(params[:embeddable_diy_sensor])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @diy_sensor.save
        render :partial => 'new', :locals => { :diy_sensor => @diy_sensor }
      else
        render :xml => @diy_sensor.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @diy_sensor.save
          flash[:notice] = 'Embeddable::Siy::diy_sensor.was successfully created.'
          format.html { redirect_to(@diy_sensor) }
          format.xml  { render :xml => @diy_sensor, :status => :created, :location => @diy_sensor }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @diy_sensor.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /Embeddable/sensors/1
  # PUT /Embeddable/sensors/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @diy_sensor = Embeddable::Diy::Sensor.find(params[:id])
    if request.xhr?
      if cancel || @diy_sensor.update_attributes(params[:embeddable_diy_sensor])
        render :partial => 'show', :locals => { :diy_sensor => @diy_sensor }
      else
        render :xml => @diy_sensor.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @diy_sensor.update_attributes(params[:embeddable_diy_sensor])
          flash[:notice] = 'Embeddable::Siy::diy_sensor.was successfully updated.'
          format.html { redirect_to(@diy_sensor) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @diy_sensor.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /Embeddable/sensors/1
  # DELETE /Embeddable/sensors/1.xml
  def destroy
    @diy_sensor = Embeddable::Diy::Sensor.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(sensors_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @diy_sensor.page_elements.each do |pe|
      pe.destroy
    end
    @diy_sensor.destroy    
  end
end
