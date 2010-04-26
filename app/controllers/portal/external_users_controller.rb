class Portal::ExternalUsersController < ApplicationController
  
  include RestrictedPortalController
  before_filter :admin_only
  
  
  protected 
  
  def setupExternalUser
    # TODO: Refactor ExternalUser to Portal::ExternalUser
    # @portal_external_user = Portal::ExternalUser.find(params[:id])
    @portal_external_user = ExternalUser.find(params[:id])
  end
  
  public
  
  
  # GET /portal_external_users
  # GET /portal_external_users.xml
  def index
    # TODO: Refactor ExternalUser to Portal::ExternalUser
    # @portal_external_users = Portal::ExternalUser.all
    @portal_external_users = ExternalUser.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @portal_external_users }
    end
  end

  # GET /portal_external_users/1
  # GET /portal_external_users/1.xml
  def show
    setupExternalUser
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @portal_external_user }
    end
  end

  # GET /portal_external_users/new
  # GET /portal_external_users/new.xml
  def new
    # TODO: Refactor ExternalUser to Portal::ExternalUser
    @portal_external_user = ExternalUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @portal_external_user }
    end
  end

  # GET /portal_external_users/1/edit
  def edit
    setupExternalUser
  end

  # POST /portal_external_users
  # POST /portal_external_users.xml
  def create
    # TODO: Refactor ExternalUser to Portal::ExternalUser
    # @portal_external_user = Portal::ExternalUser.new(params[:external_user])
    @portal_external_user = ExternalUser.new(params[:external_user])
    
    respond_to do |format|
      if @portal_external_user.save
        flash[:notice] = 'ExternalUser was successfully created.'
        format.html { redirect_to(@portal_external_user) }
        format.xml  { render :xml => @portal_external_user, :status => :created, :location => @portal_external_user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @portal_external_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /portal_external_users/1
  # PUT /portal_external_users/1.xml
  def update
    setupExternalUser
    respond_to do |format|
      if @portal_external_user.update_attributes(params[:external_user])
        flash[:notice] = 'ExternalUser was successfully updated.'
        format.html { redirect_to(@portal_external_user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @portal_external_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /portal_external_users/1
  # DELETE /portal_external_users/1.xml
  def destroy
    setupExternalUser
    @portal_external_user.destroy

    respond_to do |format|
      format.html { redirect_to(portal_external_users_url) }
      format.xml  { head :ok }
    end
  end
end
