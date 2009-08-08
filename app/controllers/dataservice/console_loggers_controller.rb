class Dataservice::ConsoleLoggersController < ApplicationController
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
