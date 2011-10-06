class HelpRequestsController < ApplicationController
  # GET /help_requests
  # GET /help_requests.xml
  def index
    if current_user.has_role?("manager")
      @help_requests = HelpRequest.find(:all,:order => "created_at DESC").paginate(:per_page => 1, :page => params[:page])
    end
    @help_request = HelpRequest.new
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @help_requests }
    end
  end

  # GET /help_requests/1
  # GET /help_requests/1.xml
  def show
    @help_request = HelpRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @help_request }
    end
  end

  # GET /help_requests/new
  # GET /help_requests/new.xml
  def new
    @help_request = HelpRequest.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @help_request }
    end
  end

  # GET /help_requests/1/edit
  def edit
    @help_request = HelpRequest.find(params[:id])
  end

  # POST /help_requests
  # POST /help_requests.xml
  def create
    help_request = params[:help_request]
    
    @environment = help_request.delete(:environment)
    help_request[:os] = get_os
    help_request[:browser] = @environment  
    @help_request = HelpRequest.new(help_request)
    

    respond_to do |format|
      if @help_request.save
        format.html { redirect_to(@help_request, :notice => 'Your help request was successfully submitted. We\'ll get back to you as soon as possible.') }
        format.xml  { render :xml => @help_request, :status => :created, :location => @help_request }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @help_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /help_requests/1
  # PUT /help_requests/1.xml
  def update
    @help_request = HelpRequest.find(params[:id])

    respond_to do |format|
      if @help_request.update_attributes(params[:help_request])
        format.html { redirect_to(@help_request, :notice => 'HelpRequest was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @help_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /help_requests/1
  # DELETE /help_requests/1.xml
  def destroy
    @help_request = HelpRequest.find(params[:id])
    @help_request.destroy

    redirect_to :action => :index
  end
  
  protected
  
  def get_os
    ua = request.env['HTTP_USER_AGENT'].downcase
    if ua.index('windows') or ua.index('win32')
      return 'windows'
    end
    if ua.index('macintosh') or ua.index('mac os x')
      return 'macintosh'
    end
    if ua.index('adobeair')
      return 'adobeair'
    end
    if ua.index('linux')
      return 'linux'
    end
    return 'unknown'
  end
  
end
