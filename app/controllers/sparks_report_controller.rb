class SparksReportController < ApplicationController
  
  def researcher_report
    
  end
  
  def class_report
    #class, activity
    @offering = Portal::Offering.find_by_id(params[:offering_id])
    @clazz = @offering.clazz
    @students = @clazz.students
    render :template => 'sparks_report/measuring_resistance/class_report'
  end
  
  ## All historical data for a student
  def learner_report
    @offering = Portal::Offering.find(params[:offering_id])
    studentId = params[:student_id] || current_user.portal_student.id
    learner = getLearner(@offering.id, studentId)
    mr = Saveable::Sparks::MeasuringResistance.find_by_learner_id(learner)
    @reports = Saveable::Sparks::MeasuringResistanceReport.find_all_by_measuring_resistance_id(mr)
    render :template => 'sparks_report/measuring_resistance/learner_report'
  end
  
  ## Data for a single session of a student
  def learner_session_report
    @report = Saveable::Sparks::MeasuringResistanceReport.find_by_id(params[:id]);
    cookies[:report_id] = @report.id
    render :template => 'sparks_report/measuring_resistance/learner_session_report'
  end
  
  ## Send back the report content in JSON format
  def get_report
    report = Saveable::Sparks::MeasuringResistanceReport.find_by_id(params[:id])
    render :json => report.content
  end

  def getLearner(offeringId, studentId)
    Portal::Learner.first(:conditions => { :offering_id => offeringId, :student_id => studentId })
  end

end
