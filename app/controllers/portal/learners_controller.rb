class Portal::LearnersController < ApplicationController

  layout 'report', :only => %w{report bundle_report}

  include RestrictedPortalController
  include Portal::LearnerJnlpRenderer

  protected

  def not_authorized_error_message
    super({resource_type: 'portal learner'})
  end

  public

  # PUNDIT_CHECK_FILTERS
  before_filter :admin_or_config, :except => [:show, :report, :activity_report]
  before_filter :teacher_admin_or_config, :only => [:activity_report]
  before_filter :handle_jnlp_session, :only => [:show]
  before_filter :authorize_show, :only => [:show]

  def current_clazz
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::Learner
    # authorize @learner
    # authorize Portal::Learner, :new_or_create?
    # authorize @learner, :update_edit_or_destroy?
    Portal::Learner.find(params[:id]).offering.clazz
  end

  def handle_jnlp_session
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::Learner
    # authorize @learner
    # authorize Portal::Learner, :new_or_create?
    # authorize @learner, :update_edit_or_destroy?
    if request.format.config? && params[:jnlp_session]
      # this will only work once for this token
      if jnlp_user = Dataservice::JnlpSession.get_user_from_token(params[:jnlp_session])
        # log out any current user because java might support persistant cookies sometime in the future
        # and we don't want an existing logged in user to mess up the sign_in process
        sign_out current_user if current_user
        # log in the user so future requests don't need a token
        sign_in jnlp_user
        # Calling sign_in without :bypass => true will cause the session to be renewed
        # when the session is renewed it means that the session id will change just before the response
        # is sent to the client.
        # which means the code to generate the config file won't have the correct session in it
        # Calling sign_in with :bypass => true skips all the warden callbacks wich means that
        # current_user is not configured
        # the hack for now is to delete the :renew flag added to session options, so the session won't be
        # renewed
        request.env['rack.session.options'].delete(:renew)
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
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::Learner
    # authorize @learner
    # authorize Portal::Learner, :new_or_create?
    # authorize @learner, :update_edit_or_destroy?
    authorized_user = (Portal::Learner.find(params[:id]).student.user == current_visitor) ||
        current_clazz.is_teacher?(current_visitor) ||
        current_visitor.has_role?('admin')
    if !authorized_user
      if request.format.config?
        raise "unauthorized config request"
      else
        force_signin
      end
    end
  end

  public

  # GET /portal/learners
  # GET /portal/learners.xml
  def index
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::Learner
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (did not find instance)
    # @learners = policy_scope(Portal::Learner)
    @portal_learners = Portal::Learner.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @portal_learners }
    end
  end

  def report
    # This report is for the teacher at the moment so for authentication
    # we just check pundit for offering report method. See reports_controller.rb

    portal_learner = Portal::Learner.find(params[:id])
    student_id = portal_learner.student_id

    offering_id = portal_learner.offering_id
    authorize Portal::Offering.find(offering_id)
    report = DefaultReportService.instance()
    offering_api_url = api_v1_report_url(offering_id,{student_ids: [student_id], activity_id: params[:activity_id]})
    next_url = report.url_for(offering_api_url, current_visitor)
    redirect_to next_url
  end

  # GET /portal/learners/1/bundle_report
  # GET /portal/learners/1/bundle_report.xml
  def bundle_report
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::Learner
    # authorize @learner
    # authorize Portal::Learner, :new_or_create?
    # authorize @learner, :update_edit_or_destroy?
    @portal_learner = Portal::Learner.find(params[:id])

    respond_to do |format|
      format.html # report.html.haml
    end
  end

  # GET /portal/learners/1
  # GET /portal/learners/1.xml
  def show
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @learner
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
        if @portal_learner.student.user == current_visitor
          if @portal_learner.bundle_logger.in_progress_bundle
            launch_event = Dataservice::LaunchProcessEvent.create(
              :event_type => Dataservice::LaunchProcessEvent::TYPES[:config_requested],
              :event_details => "Activity configuration loaded. Loading prior learner session data...",
              :bundle_content => @portal_learner.bundle_logger.in_progress_bundle
            )
          end
          bundle_post_url = dataservice_bundle_logger_bundle_contents_url(@portal_learner.bundle_logger, :format => :bundle)
        else
          bundle_post_url = nil
          properties['otrunk.view.user_data_warning'] = 'true'
        end
        if current_settings.use_periodic_bundle_uploading?
          bundle_get_url = dataservice_periodic_bundle_logger_url(@portal_learner.periodic_bundle_logger, :format => :bundle)
          bundle_post_url = nil
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
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::Learner
    @portal_learner = Portal::Learner.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @portal_learner }
    end
  end

  # GET /portal/learners/1/edit
  def edit
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @learner
    @portal_learner = Portal::Learner.find(params[:id])
  end

  # POST /portal/learners
  # POST /portal/learners.xml
  def create
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::Learner
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
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @learner
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
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @learner
    @portal_learner = Portal::Learner.find(params[:id])
    @portal_learner.destroy

    respond_to do |format|
      format.html { redirect_to(portal_learners_url) }
      format.xml  { head :ok }
    end
  end
end
