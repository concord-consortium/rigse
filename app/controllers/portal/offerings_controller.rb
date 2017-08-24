class Portal::OfferingsController < ApplicationController
  include Portal::LearnerJnlpRenderer

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
      format.run_sparks_html   {
        if learner = setup_portal_student
          session[:put_path] = saveable_sparks_measuring_resistance_url(:format => :json)
        else
          session[:put_path] = nil
        end
        render 'pages/show', :layout => "layouts/run"
      }

      format.run_resource_html   {
         if learner = setup_portal_student
           cookies[:save_path] = @offering.runnable.save_path
           cookies[:learner_id] = learner.id
           cookies[:student_name] = "#{current_visitor.first_name} #{current_visitor.last_name}"
           cookies[:activity_name] = @offering.runnable.name
           cookies[:class_id] = learner.offering.clazz.id
           cookies[:student_id] = learner.student.id
           cookies[:runnable_id] = @offering.runnable.id
           # session[:put_path] = saveable_sparks_measuring_resistance_url(:format => :json)
         else
           # session[:put_path] = nil
         end
         external_activity = @offering.runnable
         if external_activity.launch_url.present?
           uri = URI.parse(external_activity.launch_url)
           uri.query = {
             :domain => root_url,
             :externalId => learner.id,
             :returnUrl => learner.remote_endpoint_url,
             :logging => @offering.clazz.logging || @offering.runnable.logging,
             :domain_uid => current_visitor.id,
             :class_info_url => @offering.clazz.class_info_url(request.protocol, request.host_with_port)
           }.to_query
           redirect_to(uri.to_s)
         else
           redirect_to(@offering.runnable.url(learner))
         end
       }

      format.jnlp {
        # check if the user is a student in this offering's class
        if learner = setup_portal_student
          render_learner_jnlp learner
        else
          # The current_visitor is a teacher (or another user acting like a teacher)
          render :partial => 'shared/installer', :locals => { :runnable => @offering.runnable, :teacher_mode => true }
        end
      }
    end
  end

  # PUT /portal_offerings/1
  # PUT /portal_offerings/1.xml
  def update
    @offering = Portal::Offering.find(params[:id])
    authorize @offering
    update_successful = @offering.update_attributes(params[:offering])
    if request.xhr?
      render :nothing => true, :status => update_successful ? 200 : 500
      return
    end
    respond_to do |format|
      if update_successful
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
          # create saveable
          create_saveable(embeddable, @offering, learner, value) if embeddable
        end
        learner.report_learner.last_run = DateTime.now
        learner.report_learner.update_fields
      end
      flash[:notice] = "Your answers have been saved."
      redirect_to :root
    else
      render :text => 'problem loading offering', :status => 500
    end
  end

  def offering_collapsed_status
    if current_visitor.portal_teacher.nil?
      render :nothing => true
      return
    end
    offering_collapsed = true
    teacher_id = current_visitor.portal_teacher.id
    portal_teacher_full_status = Portal::TeacherFullStatus.find_or_create_by_offering_id_and_teacher_id(params[:id],teacher_id)

    offering_collapsed = (portal_teacher_full_status.offering_collapsed.nil?)? false : !portal_teacher_full_status.offering_collapsed

    portal_teacher_full_status.offering_collapsed = offering_collapsed
    portal_teacher_full_status.save!

    render :nothing => true

  end

  def get_recent_student_report
    offering = Portal::Offering.find(params[:id])
    authorize offering
    students = offering.clazz.students
    if !students.nil? && students.length > 0
      students = students.sort{|a,b| a.user.full_name.downcase<=>b.user.full_name.downcase}
    end
    learners = offering.learners
    progress_report = ""
    div_id = "DivHideShowDetail"+ offering.id.to_s
    render :update do |page|
      page.replace_html(div_id, :partial => "home/recent_student_report", :locals => { :offering => offering, :students=>students, :learners=>learners})
      page << "setRecentActivityTableHeaders(null,#{params[:id]})"
    end
    return
  end



  # report shown to students
  def student_report
    offering_id = params[:id]
    offering = Portal::Offering.find(offering_id)
    authorize offering
    student_id = current_visitor.portal_student.id
    report = DefaultReportService.instance()
    offering_api_url = api_v1_report_url(offering_id,{student_ids: [student_id]})
    next_url = report.url_for(offering_api_url, current_visitor)
    redirect_to next_url
  end

  def report
    offering_id = params[:id]
    activity_id = params[:activity_id] # Might be null
    authorize Portal::Offering.find(offering_id)
    report = DefaultReportService.instance()
    offering_api_url = api_v1_report_url(offering_id, {activity_id: activity_id})
    next_url = report.url_for(offering_api_url, current_visitor)
    redirect_to next_url
  end

  def external_report
    offering_id = params[:id]
    authorize Portal::Offering.find(offering_id)
    report_id = params[:report_id]
    report = ExternalReport.find(report_id)
    next_url = report.url_for(offering_id, current_visitor, request.protocol, request.host_with_port)
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

  def create_saveable(embeddable, offering, learner, answer)
    case embeddable
    when Embeddable::OpenResponse
      saveable_open_response = Saveable::OpenResponse.find_or_create_by_learner_id_and_offering_id_and_open_response_id(learner.id, offering.id, embeddable.id)
      if saveable_open_response.response_count == 0 || saveable_open_response.answers.last.answer != answer
        saveable_open_response.answers.create(:bundle_content_id => nil, :answer => answer)
      end
    when Embeddable::MultipleChoice
      choice = parse_embeddable(answer)
      answer = choice ? choice.choice : ""
      if embeddable && choice
        saveable = Saveable::MultipleChoice.find_or_create_by_learner_id_and_offering_id_and_multiple_choice_id(learner.id, offering.id, embeddable.id)
        if saveable.answers.empty? || saveable.answers.last.answer.first[:answer] != answer
          saveable_answer = saveable.answers.create(:bundle_content_id => nil)
          Saveable::MultipleChoiceRationaleChoice.create(:choice_id => choice.id, :answer_id => saveable_answer.id)
        end
      else
        if ! choice
          logger.error("Missing Embeddable::MultipleChoiceChoice id: #{choice_id}")
        elsif ! embeddable
          logger.error("Missing Embeddable::MultipleChoice id: #{choice.multiple_choice_id}")
        end
      end
    else
      nil
    end
  end

end
