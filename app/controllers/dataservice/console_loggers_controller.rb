class Dataservice::ConsoleLoggersController < ApplicationController

  before_filter :admin_only
  
  protected  

  def admin_only
    unless current_user.has_role?('admin') || request.format == :bundle
      flash[:notice] = "Please log in as an administrator" 
      redirect_to(:home)
    end
  end
  
  public



    # GET /dataservice_dataservice_bundle_loggers
    # GET /dataservice_dataservice_bundle_loggers.xml
    def index
      @dataservice_bundle_loggers = Dataservice::BundleLogger.search(params[:search], params[:page], nil)

      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @dataservice_bundle_loggers }
      end
    end

    # GET /dataservice_dataservice_bundle_loggers/1
    # GET /dataservice_dataservice_bundle_loggers/1.xml
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

    # GET /dataservice_dataservice_bundle_loggers/new
    # GET /dataservice_dataservice_bundle_loggers/new.xml
    def new
      @dataservice_bundle_logger = Dataservice::BundleLogger.new

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @dataservice_bundle_logger }
      end
    end

    # GET /dataservice_dataservice_bundle_loggers/1/edit
    def edit
      @dataservice_bundle_logger = Dataservice::BundleLogger.find(params[:id])
    end

    # POST /dataservice_dataservice_bundle_loggers
    # POST /dataservice_dataservice_bundle_loggers.xml
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

    # PUT /dataservice_dataservice_bundle_loggers/1
    # PUT /dataservice_dataservice_bundle_loggers/1.xml
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

    # DELETE /dataservice_dataservice_bundle_loggers/1
    # DELETE /dataservice_dataservice_bundle_loggers/1.xml
    def destroy
      @dataservice_bundle_logger = Dataservice::BundleLogger.find(params[:id])
      @dataservice_bundle_logger.destroy

      respond_to do |format|
        format.html { redirect_to(dataservice_dataservice_bundle_loggers_url) }
        format.xml  { head :ok }
      end
    end
  end

  
  # GET /dataservice_console_loggers
  # GET /dataservice_console_loggers.xml
  def index
    @dataservice_console_loggers = Dataservice::ConsoleLogger.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dataservice_console_loggers }
    end
  end

  # GET /dataservice_console_loggers/1
  # GET /dataservice_console_loggers/1.xml
  def show
    @console_logger = Dataservice::ConsoleLogger.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @console_logger }
    end
    @dataservice_console_logger = Dataservice::ConsoleLogger.find(params[:id])
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

  # GET /dataservice_console_loggers/new
  # GET /dataservice_console_loggers/new.xml
  def new
    @console_logger = Dataservice::ConsoleLogger.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @console_logger }
    end
  end

  # GET /dataservice_console_loggers/1/edit
  def edit
    @console_logger = Dataservice::ConsoleLogger.find(params[:id])
  end

  # POST /dataservice_console_loggers
  # POST /dataservice_console_loggers.xml
  def create
    @console_logger = Dataservice::ConsoleLogger.new(params[:console_logger])

    respond_to do |format|
      if @console_logger.save
        flash[:notice] = 'Dataservice::ConsoleLogger was successfully created.'
        format.html { redirect_to(@console_logger) }
        format.xml  { render :xml => @console_logger, :status => :created, :location => @console_logger }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @console_logger.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /dataservice_console_loggers/1
  # PUT /dataservice_console_loggers/1.xml
  def update
    @console_logger = Dataservice::ConsoleLogger.find(params[:id])

    respond_to do |format|
      if @console_logger.update_attributes(params[:console_logger])
        flash[:notice] = 'Dataservice::ConsoleLogger was successfully updated.'
        format.html { redirect_to(@console_logger) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @console_logger.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dataservice_console_loggers/1
  # DELETE /dataservice_console_loggers/1.xml
  def destroy
    @console_logger = Dataservice::ConsoleLogger.find(params[:id])
    @console_logger.destroy

    respond_to do |format|
      format.html { redirect_to(dataservice_console_loggers_url) }
      format.xml  { head :ok }
    end
  end
end
