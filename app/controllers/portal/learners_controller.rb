class Portal::LearnersController < ApplicationController
  # GET /portal_learners
  # GET /portal_learners.xml
  def index
    @learners = Portal::Learner.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @learners }
    end
  end

  # GET /portal_learners/1
  # GET /portal_learners/1.xml
  def show
    @learner = Portal::Learner.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.config { render :partial => 'shared/learn', 
        :locals => { :runnable => @learner.offering.runnable, 
                     :console_logger => @learner.console_logger, 
                     :bundle_logger => @learner.bundle_logger } }            
      
      format.xml  { render :xml => @learner }
    end
  end

  # GET /portal_learners/new
  # GET /portal_learners/new.xml
  def new
    @learner = Portal::Learner.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @learner }
    end
  end

  # GET /portal_learners/1/edit
  def edit
    @learner = Portal::Learner.find(params[:id])
  end

  # POST /portal_learners
  # POST /portal_learners.xml
  def create
    @learner = Portal::Learner.new(params[:learner])

    respond_to do |format|
      if @learner.save
        flash[:notice] = 'Portal::Learner was successfully created.'
        format.html { redirect_to(@learner) }
        format.xml  { render :xml => @learner, :status => :created, :location => @learner }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @learner.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /portal_learners/1
  # PUT /portal_learners/1.xml
  def update
    @learner = Portal::Learner.find(params[:id])

    respond_to do |format|
      if @learner.update_attributes(params[:learner])
        flash[:notice] = 'Portal::Learner was successfully updated.'
        format.html { redirect_to(@learner) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @learner.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /portal_learners/1
  # DELETE /portal_learners/1.xml
  def destroy
    @learner = Portal::Learner.find(params[:id])
    @learner.destroy

    respond_to do |format|
      format.html { redirect_to(portal_learners_url) }
      format.xml  { head :ok }
    end
  end
end
