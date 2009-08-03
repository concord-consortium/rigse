class Portal::OfferingsController < ApplicationController
  # GET /portal_offerings
  # GET /portal_offerings.xml
  def index
    @portal_offerings = Portal::Offering.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @portal_offerings }
    end
  end

  # GET /portal_offerings/1
  # GET /portal_offerings/1.xml
  def show
    @offering = Portal::Offering.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @offering }
      format.jnlp {
        # check if the user is a student in this offering's class
        student = current_user.portal_student
        # create a learner for the user if it doesnt' exist
        learner = @offering.find_or_create_learner(student)        
        # render a jnlp for this learner
        # render :partial => 'shared/jnlp_for_learner', :locals => {:learner => learner}
        # render :partial => 'shared/jnlp_for_learner', :locals => {:learner => learner}
        
        render :partial => 'shared/learn', :locals => { :runnable => @offering.runnable, :learner => learner }
        
      }
    end
  end
  
  # GET /portal_offerings/new
  # GET /portal_offerings/new.xml
  def new
    @offering = Portal::Offering.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @offering }
    end
  end

  # GET /portal_offerings/1/edit
  def edit
    @offering = Portal::Offering.find(params[:id])
  end

  # POST /portal_offerings
  # POST /portal_offerings.xml
  def create
    @offering = Portal::Offering.new(params[:offering])

    respond_to do |format|
      if @offering.save
        flash[:notice] = 'Portal::Offering was successfully created.'
        format.html { redirect_to(@offering) }
        format.xml  { render :xml => @offering, :status => :created, :location => @offering }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @offering.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /portal_offerings/1
  # PUT /portal_offerings/1.xml
  def update
    @offering = Portal::Offering.find(params[:id])

    respond_to do |format|
      if @offering.update_attributes(params[:offering])
        flash[:notice] = 'Portal::Offering was successfully updated.'
        format.html { redirect_to(@offering) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @offering.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /portal_offerings/1
  # DELETE /portal_offerings/1.xml
  def destroy
    @offering = Portal::Offering.find(params[:id])
    @offering.destroy

    respond_to do |format|
      format.html { redirect_to(portal_offerings_url) }
      format.xml  { head :ok }
    end
  end
end
