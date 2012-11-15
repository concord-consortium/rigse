class Portal::LearnersController < ApplicationController

  layout 'report', :only => %w{report open_response_report multiple_choice_report bundle_report}
  
  include RestrictedPortalController
  include Portal::LearnerJnlpRenderer

  before_filter :admin_or_config, :except => [:show, :report, :open_response_report, :multiple_choice_report,:activity_report]
  before_filter :teacher_admin_or_config, :only => [:report, :open_response_report, :multiple_choice_report,:activity_report]
  before_filter :handle_jnlp_session, :only => [:show]
  before_filter :authorize_show, :only => [:show]
  
  def current_clazz
    Portal::Learner.find(params[:id]).offering.clazz
  end
  
  def handle_jnlp_session
    if request.format.config? && params[:jnlp_session]
      # this will only work once for this token
      if jnlp_user = Dataservice::JnlpSession.get_user_from_token(params[:jnlp_session])
        # store this user in the rails session so future request use this user
        self.current_user = jnlp_user
      else
        # no valid jnlp_session could be found for this token
        render :partial => 'shared/sail',
          :formats => [:config],
          :locals => {
            :otml_url => "#{APP_CONFIG[:site_url]}/otml/invalid-jnlp-session.otml"
          }
      end
    end
  end

  def authorize_show
    authorized_user = (Portal::Learner.find(params[:id]).student.user == current_user) ||
        current_clazz.is_teacher?(current_user) ||
        current_user.has_role?('admin')
    if !authorized_user
      if request.format.config?
        raise "unauthorized config request"
      else
        redirect_home
      end
    end
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
  
  def activity_report
    portal_learner = Portal::Learner.find(params[:id])
    @offering = portal_learner.offering
    if params[:activity_id]
      activity = ::Activity.find(params[:activity_id].to_i)
      unless activity.nil?
        session[:activity_report_embeddable_filter] = activity.page_elements.map{|pe|pe.embeddable}
        session[:activity_report_id] = activity.id
      end
    end
    redirect_url = report_portal_learner_url(portal_learner);
    respond_to do |format|
      format.html { redirect_to redirect_url }
      format.xml  { head :ok }
    end
  end
  
  def report
    @portal_learner = Portal::Learner.find(params[:id])
    @activity_report_id = nil
    offering = @portal_learner.offering
    unless offering.report_embeddable_filter.nil? || offering.report_embeddable_filter.embeddables.nil?
      @report_embeddable_filter = offering.report_embeddable_filter.embeddables
    end
    activity_report_embeddable_filter = session[:activity_report_embeddable_filter] 
    unless activity_report_embeddable_filter.nil?
      @portal_learner.offering.report_embeddable_filter.embeddables = activity_report_embeddable_filter
      @portal_learner.offering.report_embeddable_filter.ignore = false
      @activity_report_id = session[:activity_report_id]
    end
    respond_to do |format|
      format.html # report.html.haml
        reportUtil = Report::Util.reload(@portal_learner.offering)  # force a reload of this offering
        session[:activity_report_embeddable_filter] = nil

        @page_elements = reportUtil.page_elements
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
    @portal_learner.periodic_bundle_logger = Dataservice::PeriodicBundleLogger.create!(:learner_id => @portal_learner.id) unless @portal_learner.periodic_bundle_logger
    
    respond_to do |format|
      format.html # show.html.erb
      format.jnlp { render_learner_jnlp @portal_learner }
      format.config { 
        # if this isn't the learner then it is launched read only
        properties = {}
        bundle_get_url = dataservice_bundle_logger_url(@portal_learner.bundle_logger, :format => :bundle)
        if @portal_learner.student.user == current_user
          if @portal_learner.bundle_logger.in_progress_bundle
            launch_event = Dataservice::LaunchProcessEvent.create(
              :event_type => Dataservice::LaunchProcessEvent::TYPES[:config_requested],
              :event_details => "Activity configuration loaded. Loading prior learner session data...",
              :bundle_content => @portal_learner.bundle_logger.in_progress_bundle
            )
          end
          bundle_post_url = dataservice_bundle_logger_bundle_contents_url(@portal_learner.bundle_logger, :format => :bundle)
          if current_project.use_periodic_bundle_uploading?
            bundle_get_url = dataservice_periodic_bundle_logger_url(@portal_learner.periodic_bundle_logger, :format => :bundle)
            bundle_post_url = nil
          end
        else
          bundle_post_url = nil
          properties['otrunk.view.user_data_warning'] = 'true'
        end
        render :partial => 'shared/sail',
          :locals => { 
            :otml_url => polymorphic_url(@portal_learner.offering.runnable, :format => :dynamic_otml, :learner_id => @portal_learner.id),
            :session_id => (params[:session] || request.env["rack.session.options"][:id]),
            :console_post_url => dataservice_console_logger_console_contents_url(@portal_learner.console_logger, :format => :bundle),
            :bundle_url => bundle_get_url,
            :bundle_post_url => bundle_post_url,
            :properties => properties
          }
      }
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
