class Probe::PhysicalUnitsController < ApplicationController
  # GET /Probe/physical_units
  # GET /Probe/physical_units.xml
  def index
    @physical_units = Probe::PhysicalUnit.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @physical_units }
    end
  end

  # GET /Probe/physical_units/1
  # GET /Probe/physical_units/1.xml
  def show
    @physical_unit = Probe::PhysicalUnit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @physical_unit }
    end
  end

  # GET /Probe/physical_units/new
  # GET /Probe/physical_units/new.xml
  def new
    @physical_unit = Probe::PhysicalUnit.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @physical_unit }
    end
  end

  # GET /Probe/physical_units/1/edit
  def edit
    @physical_unit = Probe::PhysicalUnit.find(params[:id])
  end

  # POST /Probe/physical_units
  # POST /Probe/physical_units.xml
  def create
    @physical_unit = Probe::PhysicalUnit.new(params[:physical_unit])

    respond_to do |format|
      if @physical_unit.save
        flash[:notice] = 'Probe::PhysicalUnit.was successfully created.'
        format.html { redirect_to(@physical_unit) }
        format.xml  { render :xml => @physical_unit, :status => :created, :location => @physical_unit }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @physical_unit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /Probe/physical_units/1
  # PUT /Probe/physical_units/1.xml
  def update
    @physical_unit = Probe::PhysicalUnit.find(params[:id])

    respond_to do |format|
      if @physical_unit.update_attributes(params[:physical_unit])
        flash[:notice] = 'Probe::PhysicalUnit.was successfully updated.'
        format.html { redirect_to(@physical_unit) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @physical_unit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /Probe/physical_units/1
  # DELETE /Probe/physical_units/1.xml
  def destroy
    @physical_unit = Probe::PhysicalUnit.find(params[:id])
    @physical_unit.destroy

    respond_to do |format|
      format.html { redirect_to(physical_units_url) }
      format.xml  { head :ok }
    end
  end
end
