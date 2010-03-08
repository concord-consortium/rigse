class Portal::ExternalUserDomainsController < ApplicationController
  
  include RestrictedPortalController
  before_filter :admin_only
  public
  
  # GET /portal_external_user_domains
  # GET /portal_external_user_domains.xml
  def index
    @portal_external_user_domains = ExternalUserDomain.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @portal_external_user_domains }
    end
  end

  # GET /portal_external_user_domains/1
  # GET /portal_external_user_domains/1.xml
  def show
    # TODO: refactor models so that externaluserdomain is in portal namespace?
    # @external_user_domain = Portal::ExternalUserDomain.find(params[:id])
    @external_user_domain = ExternalUserDomain.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @external_user_domain }
    end
  end

  # GET /portal_external_user_domains/new
  # GET /portal_external_user_domains/new.xml
  def new
    # TODO: refactor models so that externaluserdomain is in portal namespace?
    # @external_user_domain = Portal::ExternalUserDomain.new
    @external_user_domain = ExternalUserDomain.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @external_user_domain }
    end
  end

  # GET /portal_external_user_domains/1/edit
  def edit
    # TODO: refactor models so that externaluserdomain is in portal namespace?
    # @external_user_domain = Portal::ExternalUserDomain.find(params[:id])
    @external_user_domain = ExternalUserDomain.find(params[:id])
  end

  # POST /portal_external_user_domains
  # POST /portal_external_user_domains.xml
  def create
    # TODO: refactor models so that externaluserdomain is in portal namespace?    
    # @external_user_domain = Portal::ExternalUserDomain.new(params[:external_user_domain])
    @external_user_domain = ExternalUserDomain.new(params[:external_user_domain])
    respond_to do |format|
      if @external_user_domain.save
        flash[:notice] = 'Portal::ExternalUserDomain was successfully created.'
        format.html { redirect_to(@external_user_domain) }
        format.xml  { render :xml => @external_user_domain, :status => :created, :location => @external_user_domain }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @external_user_domain.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /portal_external_user_domains/1
  # PUT /portal_external_user_domains/1.xml
  def update
    # TODO: refactor models so that externaluserdomain is in portal namespace?
    # @external_user_domain = Portal::ExternalUserDomain.find(params[:id])
    @external_user_domain = ExternalUserDomain.find(params[:id])
    respond_to do |format|
      if @external_user_domain.update_attributes(params[:external_user_domain])
        flash[:notice] = 'Portal::ExternalUserDomain was successfully updated.'
        format.html { redirect_to(@external_user_domain) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @external_user_domain.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /portal_external_user_domains/1
  # DELETE /portal_external_user_domains/1.xml
  def destroy
    # TODO: refactor models so that externaluserdomain is in portal namespace?
    # @external_user_domain = Portal::ExternalUserDomain.find(params[:id])
    @external_user_domain = ExternalUserDomain.find(params[:id])
    @external_user_domain.destroy

    respond_to do |format|
      format.html { redirect_to(portal_external_user_domains_url) }
      format.xml  { head :ok }
    end
  end
end
