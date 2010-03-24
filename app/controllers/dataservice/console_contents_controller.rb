class Dataservice::ConsoleContentsController < ApplicationController
  # restrict access to admins or bundle formatted requests 
  include RestrictedBundleController
  
  # GET /dataservice_console_contents
  # GET /dataservice_console_contents.xml
  def index
    # 
    # @dataservice_console_contents = Dataservice::ConsoleContent.all
    @dataservice_console_contents = Dataservice::ConsoleContent.search(params[:search], params[:page], nil)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dataservice_console_contents }
    end
  end

  # GET /dataservice_console_contents/1
  # GET /dataservice_console_contents/1.xml
  def show
    @console_content = Dataservice::ConsoleContent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @console_content }
    end
  end

  # GET /dataservice_console_contents/new
  # GET /dataservice_console_contents/new.xml
  def new
    @console_content = Dataservice::ConsoleContent.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @console_content }
    end
  end

  # GET /dataservice_console_contents/1/edit
  def edit
    @console_content = Dataservice::ConsoleContent.find(params[:id])
  end

  # POST /dataservice_console_contents
  # POST /dataservice_console_contents.xml
  def create
    @console_content = Dataservice::ConsoleContent.new(params[:console_content])

    respond_to do |format|
      if @console_content.save
        flash[:notice] = 'Dataservice::ConsoleContent was successfully created.'
        format.html { redirect_to(@console_content) }
        format.xml  { render :xml => @console_content, :status => :created, :location => @console_content }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @console_content.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /dataservice_console_contents/1
  # PUT /dataservice_console_contents/1.xml
  def update
    @console_content = Dataservice::ConsoleContent.find(params[:id])

    respond_to do |format|
      if @console_content.update_attributes(params[:console_content])
        flash[:notice] = 'Dataservice::ConsoleContent was successfully updated.'
        format.html { redirect_to(@console_content) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @console_content.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dataservice_console_contents/1
  # DELETE /dataservice_console_contents/1.xml
  def destroy
    @console_content = Dataservice::ConsoleContent.find(params[:id])
    @console_content.destroy

    respond_to do |format|
      format.html { redirect_to(dataservice_console_contents_url) }
      format.xml  { head :ok }
    end
  end
end
