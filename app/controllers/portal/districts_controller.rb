class Portal::DistrictsController < ApplicationController
  # GET /portal_districts
  # GET /portal_districts.xml
  def index
    @districts = Portal::District.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @districts }
    end
  end

  # GET /portal_districts/1
  # GET /portal_districts/1.xml
  def show
    @district = Portal::District.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @district }
    end
  end

  # GET /portal_districts/new
  # GET /portal_districts/new.xml
  def new
    @district = Portal::District.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @district }
    end
  end

  # GET /portal_districts/1/edit
  def edit
    @district = Portal::District.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :district => @district }
    else
      respond_to do |format|
        format.html
        format.xml  { render :xml => @district }
      end
    end
  end

  # POST /portal_districts
  # POST /portal_districts.xml
  def create
    @district = Portal::District.new(params[:district])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @district.save
        render :partial => 'new', :locals => { :district => @district }
      else
        render :xml => @district.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @district.save
          flash[:notice] = 'Portal::District was successfully created.'
          format.html { redirect_to(@district) }
          format.xml  { render :xml => @district, :status => :created, :location => @district }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @district.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /portal_districts/1
  # PUT /portal_districts/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @district = Portal::District.find(params[:id])
    if request.xhr?
      if cancel || @district.update_attributes(params[:district])
        render :partial => 'show', :locals => { :district => @district }
      else
        render :xml => @district.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @district.update_attributes(params[:district])
          flash[:notice] = 'Portal::District was successfully updated.'
          format.html { redirect_to(@district) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @district.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /portal_districts/1
  # DELETE /portal_districts/1.xml
  def destroy
    @district = Portal::District.find(params[:id])
    @district.destroy

    respond_to do |format|
      format.html { redirect_to(portal_districts_url) }
      format.xml  { head :ok }
    end
  end
end
