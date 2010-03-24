class Portal::LearnersController < ApplicationController

  layout 'report', :only => %w{report open_response_report multiple_choice_report bundle_report}
  
  include RestrictedPortalController
  
  before_filter :admin_or_config, :except => [:report, :open_response_report, :multiple_choice_report]
  before_filter :teacher_admin_or_config, :only => [:report, :open_response_report, :multiple_choice_report]
  
  def current_clazz
    Portal::Learner.find(params[:id]).offering.clazz
  end
  
  public

  # GET /portal/learners
  # GET /portal/learners.xml
  def index
    @portal_learners = Portal::Learner.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @portal_learners }
    end
  end

  # GET /portal/learners/1/open_response_report
  # GET /portal/learners/1/open_response_report.xml
  def open_response_report
    @portal_learner = Portal::Learner.find(params[:id])
    
    respond_to do |format|
      format.html # report.html.haml
    end
  end
  
  # GET /portal/learners/1/multiple_choice_report
  # GET /portal/learners/1/multiple_choice_report.xml
  def multiple_choice_report
    @portal_learner = Portal::Learner.find(params[:id])
    
    respond_to do |format|
      format.html # report.html.haml
    end
  end
  
  def report
    @portal_learner = Portal::Learner.find(params[:id])
    
    reportUtil = Report::Util.reload(@portal_learner.offering)  # force a reload of this offering
    
    @page_elements = reportUtil.page_elements
    
    respond_to do |format|
      format.html # report.html.haml
    end
  end

  # GET /portal/learners/1/bundle_report
  # GET /portal/learners/1/bundle_report.xml
  def bundle_report
    @portal_learner = Portal::Learner.find(params[:id])
    
    respond_to do |format|
      format.html # report.html.haml
    end
  end

  # GET /portal/learners/1
  # GET /portal/learners/1.xml
  def show
    @portal_learner = Portal::Learner.find(params[:id])
    
    @portal_learner.console_logger = Dataservice::ConsoleLogger.create! unless @portal_learner.console_logger
    @portal_learner.bundle_logger = Dataservice::BundleLogger.create! unless @portal_learner.bundle_logger
    
    respond_to do |format|
      format.html # show.html.erb
      format.config { render :partial => 'shared/learn', 
        :locals => { :runnable => @portal_learner.offering.runnable, 
                     :console_logger => @portal_learner.console_logger, 
                     :bundle_logger => @portal_learner.bundle_logger,
                     :session_id => (params[:session] || request.env["rack.session.options"][:id]) } }            
      
      format.xml  { render :xml => @portal_learner }
    end
  end

  # GET /portal/learners/new
  # GET /portal/learners/new.xml
  def new
    @portal_learner = Portal::Learner.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @portal_learner }
    end
  end

  # GET /portal/learners/1/edit
  def edit
    @portal_learner = Portal::Learner.find(params[:id])
  end

  # POST /portal/learners
  # POST /portal/learners.xml
  def create
    @portal_learner = Portal::Learner.new(params[:learner])

    respond_to do |format|
      if @portal_learner.save
        flash[:notice] = 'Portal::Learner was successfully created.'
        format.html { redirect_to(@portal_learner) }
        format.xml  { render :xml => @portal_learner, :status => :created, :location => @portal_learner }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @portal_learner.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /portal/learners/1
  # PUT /portal/learners/1.xml
  def update
    @portal_learner = Portal::Learner.find(params[:id])

    respond_to do |format|
      if @portal_learner.update_attributes(params[:learner])
        flash[:notice] = 'Portal::Learner was successfully updated.'
        format.html { redirect_to(@portal_learner) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @portal_learner.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /portal/learners/1
  # DELETE /portal/learners/1.xml
  def destroy
    @portal_learner = Portal::Learner.find(params[:id])
    @portal_learner.destroy

    respond_to do |format|
      format.html { redirect_to(portal_learners_url) }
      format.xml  { head :ok }
    end
  end
end
