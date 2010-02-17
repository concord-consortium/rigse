class SparksReportController < ApplicationController
  
  #layout 'sparks_report'
  
  def learner_report
    @offering = Portal::Offering.find(params[:offering_id])
    @learner = get_learner
    @mr = Saveable::Sparks::MeasuringResistance.find_by_learner_id(@learner.id)
    @reports = Saveable::Sparks::MeasuringResistanceReport.find_all_by_measuring_resistance_id(@mr.id)
    render :template => 'sparks_report/measuring_resistance/learner_report'
  end
  
  def learner_session_report
    @report = Saveable::Sparks::MeasuringResistanceReport.find_by_id(params[:id]);
    cookies[:report_id] = @report.id
    render :template => 'sparks_report/measuring_resistance/learner_session_report'
  end
  
  def get_learner
    Portal::Learner.find_by_student_id(current_user.portal_student)
  end
  
  ## Send back the report content in JSON format
  def get_report
    report = Saveable::Sparks::MeasuringResistanceReport.find_by_id(params[:id])
    render :json => report.content
  end

end
