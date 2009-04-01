class PhysicalUnitsController < ApplicationController
  # GET /physical_units
  # GET /physical_units.xml
  def index
    @physical_units = PhysicalUnit.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @physical_units }
    end
  end

  # GET /physical_units/1
  # GET /physical_units/1.xml
  def show
    @physical_unit = PhysicalUnit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @physical_unit }
    end
  end

  # GET /physical_units/new
  # GET /physical_units/new.xml
  def new
    @physical_unit = PhysicalUnit.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @physical_unit }
    end
  end

  # GET /physical_units/1/edit
  def edit
    @physical_unit = PhysicalUnit.find(params[:id])
  end

  # POST /physical_units
  # POST /physical_units.xml
  def create
    @physical_unit = PhysicalUnit.new(params[:physical_unit])

    respond_to do |format|
      if @physical_unit.save
        flash[:notice] = 'PhysicalUnit was successfully created.'
        format.html { redirect_to(@physical_unit) }
        format.xml  { render :xml => @physical_unit, :status => :created, :location => @physical_unit }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @physical_unit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /physical_units/1
  # PUT /physical_units/1.xml
  def update
    @physical_unit = PhysicalUnit.find(params[:id])

    respond_to do |format|
      if @physical_unit.update_attributes(params[:physical_unit])
        flash[:notice] = 'PhysicalUnit was successfully updated.'
        format.html { redirect_to(@physical_unit) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @physical_unit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /physical_units/1
  # DELETE /physical_units/1.xml
  def destroy
    @physical_unit = PhysicalUnit.find(params[:id])
    @physical_unit.destroy

    respond_to do |format|
      format.html { redirect_to(physical_units_url) }
      format.xml  { head :ok }
    end
  end
end
