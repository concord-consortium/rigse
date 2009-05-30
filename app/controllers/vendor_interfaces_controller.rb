class VendorInterfacesController < ApplicationController
  # GET /vendor_interfaces
  # GET /vendor_interfaces.xml
  def index
    @vendor_interfaces = VendorInterface.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @vendor_interfaces }
    end
  end

  # GET /vendor_interfaces/1
  # GET /vendor_interfaces/1.xml
  def show
    @vendor_interface = VendorInterface.find(params[:id])
    if request.xhr?
      render :partial => 'vendor_interface', :locals => { :vendor_interface => @vendor_interface }
    else
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @vendor_interface }
      end
    end
  end

  # GET /vendor_interfaces/new
  # GET /vendor_interfaces/new.xml
  def new
    @vendor_interface = VendorInterface.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @vendor_interface }
    end
  end

  # GET /vendor_interfaces/1/edit
  def edit
    @vendor_interface = VendorInterface.find(params[:id])
  end

  # POST /vendor_interfaces
  # POST /vendor_interfaces.xml
  def create
    @vendor_interface = VendorInterface.new(params[:vendor_interface])

    respond_to do |format|
      if @vendor_interface.save
        flash[:notice] = 'VendorInterface was successfully created.'
        format.html { redirect_to(@vendor_interface) }
        format.xml  { render :xml => @vendor_interface, :status => :created, :location => @vendor_interface }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @vendor_interface.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /vendor_interfaces/1
  # PUT /vendor_interfaces/1.xml
  def update
    @vendor_interface = VendorInterface.find(params[:id])

    respond_to do |format|
      if @vendor_interface.update_attributes(params[:vendor_interface])
        flash[:notice] = 'VendorInterface was successfully updated.'
        format.html { redirect_to(@vendor_interface) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @vendor_interface.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /vendor_interfaces/1
  # DELETE /vendor_interfaces/1.xml
  def destroy
    @vendor_interface = VendorInterface.find(params[:id])
    @vendor_interface.destroy

    respond_to do |format|
      format.html { redirect_to(vendor_interfaces_url) }
      format.xml  { head :ok }
    end
  end
end
