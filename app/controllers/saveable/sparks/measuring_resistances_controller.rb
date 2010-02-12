class Saveable::Sparks::MeasuringResistancesController < ApplicationController
  # GET /saveable/sparks/measuring_resistances
  # GET /saveable/sparks/measuring_resistances.json
  def index
    @measuring_resistances = Saveable::Sparks::MeasuringResistance.all

    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :xml => @measuring_resistances }
    end
  end

  # GET /saveable/sparks/measuring_resistances/1
  # GET /saveable/sparks/measuring_resistances/1.json
  def show
    
    @measuring_resistance = Saveable::Sparks::MeasuringResistance.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :layout => false, :json => @measuring_resistance.reports.last.content.to_json }
      format.json  { render :xml => @measuring_resistance }
    end
  end

  # GET /saveable/sparks/measuring_resistances/new
  # GET /saveable/sparks/measuring_resistances/new.json
  def new
    @measuring_resistance = Saveable::Sparks::MeasuringResistance.new

    respond_to do |format|
      format.html # new.html.erb
      format.json  { render :xml => @measuring_resistance }
    end
  end

  # GET /saveable/sparks/measuring_resistances/1/edit
  def edit
    @measuring_resistance = Saveable::Sparks::MeasuringResistance.find(params[:id])
  end

  # POST /saveable/sparks/measuring_resistances
  # POST /saveable/sparks/measuring_resistances.json
  def create
    @measuring_resistance = Saveable::Sparks::MeasuringResistance.new(params[:measuring_resistance])

    respond_to do |format|
      if @measuring_resistance.save
        flash[:notice] = 'Saveable::Sparks::MeasuringResistance.was successfully created.'
        format.html { redirect_to(@measuring_resistance) }
        format.json { redirect_to(@measuring_resistance) }
        format.json  { render :xml => @measuring_resistance, :status => :created, :location => @measuring_resistance }
      else
        format.html { render :action => "new" }
        format.json  { render :xml => @measuring_resistance.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /saveable/sparks/measuring_resistances/1
  # PUT /saveable/sparks/measuring_resistances/1.json
  def update
    @measuring_resistance = Saveable::Sparks::MeasuringResistance.find(params[:id])

    respond_to do |format|
      if @measuring_resistance.update_attributes(params[:measuring_resistance])
        flash[:notice] = 'Saveable::Sparks::MeasuringResistance.was successfully updated.'
        format.html { redirect_to(@measuring_resistance) }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.json  { render :xml => @measuring_resistance.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /saveable/sparks/measuring_resistances/1
  # DELETE /saveable/sparks/measuring_resistances/1.json
  def destroy
    @measuring_resistance = Saveable::Sparks::MeasuringResistance.find(params[:id])
    @measuring_resistance.destroy

    respond_to do |format|
      format.html { redirect_to(measuring_resistances_url) }
      format.json  { head :ok }
    end
  end
end
