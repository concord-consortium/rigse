class Portal::ExternalUsersController < ApplicationController
  # GET /portal_external_users
  # GET /portal_external_users.xml
  def index
    @portal_external_users = Portal::ExternalUser.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @portal_external_users }
    end
  end

  # GET /portal_external_users/1
  # GET /portal_external_users/1.xml
  def show
    @external_user = Portal::ExternalUser.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @external_user }
    end
  end

  # GET /portal_external_users/new
  # GET /portal_external_users/new.xml
  def new
    @external_user = Portal::ExternalUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @external_user }
    end
  end

  # GET /portal_external_users/1/edit
  def edit
    @external_user = Portal::ExternalUser.find(params[:id])
  end

  # POST /portal_external_users
  # POST /portal_external_users.xml
  def create
    @external_user = Portal::ExternalUser.new(params[:external_user])

    respond_to do |format|
      if @external_user.save
        flash[:notice] = 'Portal::ExternalUser was successfully created.'
        format.html { redirect_to(@external_user) }
        format.xml  { render :xml => @external_user, :status => :created, :location => @external_user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @external_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /portal_external_users/1
  # PUT /portal_external_users/1.xml
  def update
    @external_user = Portal::ExternalUser.find(params[:id])

    respond_to do |format|
      if @external_user.update_attributes(params[:external_user])
        flash[:notice] = 'Portal::ExternalUser was successfully updated.'
        format.html { redirect_to(@external_user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @external_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /portal_external_users/1
  # DELETE /portal_external_users/1.xml
  def destroy
    @external_user = Portal::ExternalUser.find(params[:id])
    @external_user.destroy

    respond_to do |format|
      format.html { redirect_to(portal_external_users_url) }
      format.xml  { head :ok }
    end
  end
end
