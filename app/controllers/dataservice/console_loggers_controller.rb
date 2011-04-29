class Dataservice::ConsoleLoggersController < ApplicationController

  # restrict access to admins or bundle formatted requests 
  include RestrictedBundleController
  
  public

  # GET /dataservice/console_loggers
  # GET /dataservice/console_loggers.xml
  def index
    @dataservice_console_loggers = Dataservice::ConsoleLogger.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dataservice_console_loggers }
    end
  end

  # GET /dataservice/console_loggers/1
  # GET /dataservice/console_loggers/1.xml
  def show
    @dataservice_console_logger = Dataservice::ConsoleLogger.find(params[:id])
    if console_content = @dataservice_console_logger.last_console_content
      eportfolio_bundle = console_content.eportfolio
    else
      eportfolio_bundle =  Dataservice::ConsoleContent::EMPTY_EPORTFOLIO_BUNDLE
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => eportfolio_bundle }
      format.bundle {render :xml => eportfolio_bundle }
    end
  end

  # GET /dataservice/console_loggers/new
  # GET /dataservice/console_loggers/new.xml
  def new
    @dataservice_console_logger = Dataservice::ConsoleLogger.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dataservice_console_logger }
    end
  end

  # GET /dataservice/console_loggers/1/edit
  def edit
    @dataservice_console_logger = Dataservice::ConsoleLogger.find(params[:id])
  end

  # POST /dataservice/console_loggers
  # POST /dataservice/console_loggers.xml
  def create
    @dataservice_console_logger = Dataservice::ConsoleLogger.new(params[:dataservice_console_logger])

    respond_to do |format|
      if @dataservice_console_logger.save
        flash[:notice] = 'Dataservice::ConsoleLogger was successfully created.'
        format.html { redirect_to(@dataservice_console_logger) }
        format.xml  { render :xml => @dataservice_console_logger, :status => :created, :location => @dataservice_console_logger }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dataservice_console_logger.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /dataservice/console_loggers/1
  # PUT /dataservice/console_loggers/1.xml
  def update
    @dataservice_console_logger = Dataservice::ConsoleLogger.find(params[:id])

    respond_to do |format|
      if @dataservice_console_logger.update_attributes(params[:dataservice_console_logger])
        flash[:notice] = 'Dataservice::ConsoleLogger was successfully updated.'
        format.html { redirect_to(@dataservice_console_logger) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dataservice_console_logger.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dataservice/console_loggers/1
  # DELETE /dataservice/console_loggers/1.xml
  def destroy
    @dataservice_console_logger = Dataservice::ConsoleLogger.find(params[:id])
    @dataservice_console_logger.destroy

    respond_to do |format|
      format.html { redirect_to(dataservice_console_loggers_url) }
      format.xml  { head :ok }
    end
  end
end
