class Dataservice::BundleLoggersController < ApplicationController
  # GET /dataservice_bundle_loggers
  # GET /dataservice_bundle_loggers.xml
  def index
    @dataservice_bundle_loggers = Dataservice::BundleLogger.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dataservice_bundle_loggers }
    end
  end

  # GET /dataservice_bundle_loggers/1
  # GET /dataservice_bundle_loggers/1.xml
  def show
    @bundle_logger = Dataservice::BundleLogger.find(params[:id])
    if bc = @bundle_logger.latest_bundle_content[0]
      content = Dataservice::BundleLogger::OPEN_ELEMENT_EPORTFOLIO + bc.body + Dataservice::BundleLogger::CLOSE_ELEMENT_EPORTFOLIO
    else
      content =  File.read(File.join(RAILS_ROOT, 'public', 'bundles', 'empty_bundle.xml'))
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => content }
      format.bundle {render :xml => content }
    end
  end

  # GET /dataservice_bundle_loggers/new
  # GET /dataservice_bundle_loggers/new.xml
  def new
    @bundle_logger = Dataservice::BundleLogger.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bundle_logger }
    end
  end

  # GET /dataservice_bundle_loggers/1/edit
  def edit
    @bundle_logger = Dataservice::BundleLogger.find(params[:id])
  end

  # POST /dataservice_bundle_loggers
  # POST /dataservice_bundle_loggers.xml
  def create
    @bundle_logger = Dataservice::BundleLogger.new(params[:bundle_logger])

    respond_to do |format|
      if @bundle_logger.save
        flash[:notice] = 'Dataservice::BundleLogger was successfully created.'
        format.html { redirect_to(@bundle_logger) }
        format.xml  { render :xml => @bundle_logger, :status => :created, :location => @bundle_logger }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bundle_logger.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /dataservice_bundle_loggers/1
  # PUT /dataservice_bundle_loggers/1.xml
  def update
    @bundle_logger = Dataservice::BundleLogger.find(params[:id])

    respond_to do |format|
      if @bundle_logger.update_attributes(params[:bundle_logger])
        flash[:notice] = 'Dataservice::BundleLogger was successfully updated.'
        format.html { redirect_to(@bundle_logger) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bundle_logger.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dataservice_bundle_loggers/1
  # DELETE /dataservice_bundle_loggers/1.xml
  def destroy
    @bundle_logger = Dataservice::BundleLogger.find(params[:id])
    @bundle_logger.destroy

    respond_to do |format|
      format.html { redirect_to(dataservice_bundle_loggers_url) }
      format.xml  { head :ok }
    end
  end
end
