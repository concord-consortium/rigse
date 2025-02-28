class Portal::LearnersController < ApplicationController

  layout 'report', :only => %w{report}

  include RestrictedPortalController

  protected

  def not_authorized_error_message
    super({resource_type: 'portal learner'})
  end

  public

  # PUNDIT_CHECK_FILTERS
  before_action :admin_only, :except => [:show, :report, :activity_report]
  before_action :teacher_admin, :only => [:activity_report]
  before_action :authorize_show, :only => [:show]

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
      force_signin
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
    offering = Portal::Offering.find(offering_id)
    authorize offering
    report = DefaultReportService::default_report_for_offering(offering)
    raise ActionController::RoutingError.new('Default Report Not Found') unless report
    next_url = report.url_for_offering(offering, current_visitor, request.protocol, request.host_with_port,
      { student_id: student_id, activity_id: params[:activity_id] }
    )
    redirect_to next_url, allow_other_host: true
  end

  # GET /portal/learners/1
  # GET /portal/learners/1.xml
  def show
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @learner
    @portal_learner = Portal::Learner.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
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
    @portal_learner = Portal::Learner.new(portal_learner_strong_params(params[:learner]))

    respond_to do |format|
      if @portal_learner.save
        flash['notice'] = 'Portal::Learner was successfully created.'
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
      if @portal_learner.update(portal_learner_strong_params(params[:learner]))
        flash['notice'] = 'Portal::Learner was successfully updated.'
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

  def portal_learner_strong_params(params)
    params && params.permit(:offering_id, :secure_key, :student_id)
  end
end
