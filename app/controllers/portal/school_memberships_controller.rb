class Portal::SchoolMembershipsController < ApplicationController
  
  include RestrictedPortalController
  # PUNDIT_CHECK_FILTERS
  before_filter :admin_only
  public
  
  # GET /portal_school_memberships
  # GET /portal_school_memberships.xml
  def index
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::SchoolMembership
    @school_memberships = Portal::SchoolMembership.all
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (found instance)
    # @school_memberships = policy_scope(Portal::SchoolMembership)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @school_memberships }
    end
  end

  # GET /portal_school_memberships/1
  # GET /portal_school_memberships/1.xml
  def show
    @school_membership = Portal::SchoolMembership.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @school_membership

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @school_membership }
    end
  end

  # GET /portal_school_memberships/new
  # GET /portal_school_memberships/new.xml
  def new
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::SchoolMembership
    @school_membership = Portal::SchoolMembership.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @school_membership }
    end
  end

  # GET /portal_school_memberships/1/edit
  def edit
    @school_membership = Portal::SchoolMembership.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @school_membership
  end

  # POST /portal_school_memberships
  # POST /portal_school_memberships.xml
  def create
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::SchoolMembership
    @school_membership = Portal::SchoolMembership.new(params[:school_membership])

    respond_to do |format|
      if @school_membership.save
        flash[:notice] = 'Portal::SchoolMembership was successfully created.'
        format.html { redirect_to(@school_membership) }
        format.xml  { render :xml => @school_membership, :status => :created, :location => @school_membership }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @school_membership.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /portal_school_memberships/1
  # PUT /portal_school_memberships/1.xml
  def update
    @school_membership = Portal::SchoolMembership.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @school_membership

    respond_to do |format|
      if @school_membership.update_attributes(params[:school_membership])
        flash[:notice] = 'Portal::SchoolMembership was successfully updated.'
        format.html { redirect_to(@school_membership) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @school_membership.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /portal_school_memberships/1
  # DELETE /portal_school_memberships/1.xml
  def destroy
    @school_membership = Portal::SchoolMembership.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @school_membership
    @school_membership.destroy

    respond_to do |format|
      format.html { redirect_to(portal_school_memberships_url) }
      format.xml  { head :ok }
    end
  end
end
