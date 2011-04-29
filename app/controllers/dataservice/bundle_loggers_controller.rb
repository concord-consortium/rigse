class Dataservice::BundleLoggersController < ApplicationController

  # restrict access to admins or bundle formatted requests 
  include RestrictedBundleController

  public
  
  # GET /dataservice/bundle_loggers
  # GET /dataservice/bundle_loggers.xml
  def index
    @dataservice_bundle_loggers = Dataservice::BundleLogger.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dataservice_bundle_loggers }
    end
  end

  # GET /dataservice/bundle_loggers/1
  # GET /dataservice/bundle_loggers/1.xml
  def show
    @dataservice_bundle_logger = Dataservice::BundleLogger.find(params[:id])
    if bundle_content = @dataservice_bundle_logger.last_non_empty_bundle_content
      eportfolio_bundle = bundle_content.eportfolio
    else
      eportfolio_bundle =  Dataservice::BundleContent::EMPTY_EPORTFOLIO_BUNDLE
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => eportfolio_bundle }
      format.bundle {render :xml => eportfolio_bundle }
    end
  end

  # GET /dataservice/bundle_loggers/new
  # GET /dataservice/bundle_loggers/new.xml
  def new
    @dataservice_bundle_logger = Dataservice::BundleLogger.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dataservice_bundle_logger }
    end
  end

  # GET /dataservice/bundle_loggers/1/edit
  def edit
    @dataservice_bundle_logger = Dataservice::BundleLogger.find(params[:id])
  end

  # POST /dataservice/bundle_loggers
  # POST /dataservice/bundle_loggers.xml
  def create
    @dataservice_bundle_logger = Dataservice::BundleLogger.new(params[:dataservice_bundle_logger])

    respond_to do |format|
      if @dataservice_bundle_logger.save
        flash[:notice] = 'Dataservice::BundleLogger was successfully created.'
        format.html { redirect_to(@dataservice_bundle_logger) }
        format.xml  { render :xml => @dataservice_bundle_logger, :status => :created, :location => @dataservice_bundle_logger }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dataservice_bundle_logger.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /dataservice/bundle_loggers/1
  # PUT /dataservice/bundle_loggers/1.xml
  def update
    @dataservice_bundle_logger = Dataservice::BundleLogger.find(params[:id])

    respond_to do |format|
      if @dataservice_bundle_logger.update_attributes(params[:dataservice_bundle_logger])
        flash[:notice] = 'Dataservice::BundleLogger was successfully updated.'
        format.html { redirect_to(@dataservice_bundle_logger) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dataservice_bundle_logger.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dataservice/bundle_loggers/1
  # DELETE /dataservice/bundle_loggers/1.xml
  def destroy
    @dataservice_bundle_logger = Dataservice::BundleLogger.find(params[:id])
    @dataservice_bundle_logger.destroy

    respond_to do |format|
      format.html { redirect_to(dataservice_bundle_loggers_url) }
      format.xml  { head :ok }
    end
  end
end
