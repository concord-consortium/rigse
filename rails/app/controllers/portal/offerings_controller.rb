class Portal::OfferingsController < ApplicationController

  protected

  def not_authorized_error_message
    additional_info = @offering && @offering.locked ? "this offering is locked" : nil
    super({resource_type: 'offering', additional_info: additional_info})
  end

  private

  def setup_portal_student
    learner = nil
    if portal_student = current_visitor.portal_student
      # create a learner for the user if one doesnt' exist
      learner = @offering.find_or_create_learner(portal_student)
    end
    learner
  end

  public

  # GET /portal_offerings/1
  # GET /portal_offerings/1.xml
  def show
    @offering = Portal::Offering.find(params[:id])
    authorize @offering

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @offering }

      format.run_html   {
        @learner = setup_portal_student
        render :show, :layout => "layouts/run"
      }

      format.run_resource_html   {
         if learner = setup_portal_student
          learner.update_last_run
           cookies[:save_path] = @offering.runnable.save_path
           cookies[:learner_id] = learner.id
           cookies[:student_name] = "#{current_visitor.first_name} #{current_visitor.last_name}"
           cookies[:activity_name] = @offering.runnable.name
           cookies[:class_id] = learner.offering.clazz.id
           cookies[:student_id] = learner.student.id
           cookies[:runnable_id] = @offering.runnable.id
         else
           # session[:put_path] = nil
         end
         external_activity = @offering.runnable
         if external_activity.lara_activity_or_sequence?
           uri = URI.parse(external_activity.url)
           uri.query = {
             :externalId => learner.id,
             :returnUrl => learner.remote_endpoint_url,
             :logging => @offering.clazz.logging || @offering.runnable.logging,
             :domain => root_url,
             :domain_uid => current_visitor.id,
             :class_info_url => @offering.clazz.class_info_url(request.protocol, request.host_with_port),
             :context_id => @offering.clazz.class_hash,
             # platform_id and platform_user_id are similiar to domain and domain_uid.
             # However, LARA uses domain and domain_uid to authenticate the user,
             # while the platform params are moving towards LTI compatible launching
             # More specifically LARA removes domain and domain_uid from URL,
             # so it is harder to use the domain params to setup the run in LARA.
             :platform_id => APP_CONFIG[:site_url],
             :platform_user_id => current_visitor.id,
             :resource_link_id => @offering.id
           }.to_query
           redirect_to(uri.to_s)
         else
           redirect_to(@offering.runnable.url(learner, root_url))
         end
       }
    end
  end

  # PUT /portal_offerings/1
  # PUT /portal_offerings/1.xml
  def update
    @offering = Portal::Offering.find(params[:id])
    authorize @offering
    update_successful = @offering.update(portal_offering_strong_params(params[:offering]))
    if request.xhr?
      status = update_successful ? 200 : 500
      head status
      return
    end
    respond_to do |format|
      if update_successful
        flash['notice'] = 'Portal::Offering was successfully updated.'
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
    authorize @offering
    @offering.destroy

    respond_to do |format|
      format.html { redirect_to(portal_offerings_url) }
      format.xml  { head :ok }
    end
  end

  def activate
    @offering = Portal::Offering.find(params[:id])
    authorize @offering
    @offering.activate!
    redirect_to :back
  end

  def deactivate
    @offering = Portal::Offering.find(params[:id])
    authorize @offering
    @offering.deactivate!
    redirect_to :back
  end

  def answers
    @offering = Portal::Offering.find(params[:id])
    authorize @offering
    if @offering
      learner = setup_portal_student
      if learner && params[:questions]
        # create saveables
        params[:questions].each do |dom_id, value|
          # translate the dom id into an actual Embeddable
          embeddable = parse_embeddable(dom_id)
        end
        learner.report_learner.last_run = DateTime.now
        learner.update_report_model_cache
      end
      flash['notice'] = "Your answers have been saved."
      redirect_to :root
    else
      render :plain => 'problem loading offering', :status => 500
    end
  end

  def offering_collapsed_status
    if current_visitor.portal_teacher.nil?
      head :ok
      return
    end
    teacher_id = current_visitor.portal_teacher.id
    portal_teacher_full_status = Portal::TeacherFullStatus.where(offering_id: params[:id],teacher_id: teacher_id).first_or_create

    offering_collapsed = (portal_teacher_full_status.offering_collapsed.nil?)? false : !portal_teacher_full_status.offering_collapsed

    portal_teacher_full_status.offering_collapsed = offering_collapsed
    portal_teacher_full_status.save!

    head :ok

  end

  # report shown to students
  def student_report
    offering_id = params[:id]
    offering = Portal::Offering.find(offering_id)
    authorize offering
    student_id = current_visitor.portal_student.id
    report = DefaultReportService::default_report_for_offering(offering)
    raise ActionController::RoutingError.new('Default Report Not Found') unless report
    next_url = report.url_for_offering(offering, current_visitor, request.protocol, request.host_with_port, { student_id: student_id })
    redirect_to next_url
  end

  # This is in fact a default external report.
  def report
    offering_id = params[:id]
    activity_id = params[:activity_id] # Might be null
    offering = Portal::Offering.find(offering_id)
    authorize offering
    report = DefaultReportService::default_report_for_offering(offering)
    raise ActionController::RoutingError.new('Default Report Not Found') unless report
    next_url = report.url_for_offering(offering, current_visitor, request.protocol, request.host_with_port, { activity_id: activity_id })
    redirect_to next_url
  end

  def external_report
    offering_id = params[:id]
    activity_id = params[:activity_id] # Might be null
    offering = Portal::Offering.find(offering_id)
    authorize offering
    report_id = params[:report_id]
    report = ExternalReport.find(report_id)
    next_url = report.url_for_offering(offering, current_visitor, request.protocol, request.host_with_port, { activity_id: activity_id })
    redirect_to next_url
  end

  private

  def parse_embeddable(dom_id)
    # make sure to support at least Embeddable::OpenResponse, Embeddable::MultipleChoice, and Embeddable::MultipleChoiceChoice
    if dom_id =~ /embeddable__([^\d]+)_(\d+)$/
      klass = "Embeddable::#{$1.classify}".constantize
      return klass.find($2.to_i) if klass
    end
    nil
  end

  def portal_offering_strong_params(params)
    params && params.permit(:active, :anonymous_report,:clazz_id, :default_offering, :locked, :position, :runnable_id, :runnable_type, :status)
  end
end
