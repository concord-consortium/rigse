class Report::LearnerController < ApplicationController

  require 'cgi'

  protected

  def not_authorized_error_message
    super({resource_type: 'report learner'})
  end

  public

  def update_learners
    authorize Report::Learner
    Portal::Learner.all.each { |l|
      l.update_report_model_cache
    }
  end

  def updated_at
    # no authorization needed ...
    learner = Report::Learner.find_by_user_id_and_offering_id(current_visitor.id,params[:id])
    if learner
      last_run = learner.last_run
      status = 400
      hasnt_run_text  = I18n.t "StudentHasntRun"
      json_response = { error_msg: hasnt_run_text }
      text_response = hasnt_run_text
      if last_run
        status = 200
        modification_time = last_run.strftime("%s")
        json_response = {modification_time: modification_time }
        text_response = modification_time
      end
      respond_to do |format|
        format.html do
          render :plain => text_response, :status => status
        end
        format.json do
          render :json => json_response, :status => status
        end
      end
    else
      head :ok
    end
  end

end
