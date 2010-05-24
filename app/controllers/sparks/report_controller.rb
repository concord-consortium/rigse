require 'json/ext'

class Sparks::ReportController < ApplicationController
  
  @@report_js = "#{RAILS_ROOT}/public/sparks-content/server-mr-report.js"
  @@sep = '|'
  
  ## INPUT:
  ##   params[:offering_id]
  def class_report_big_table
    @offering = Portal::Offering.find_by_id(params[:offering_id])
    @clazz = @offering.clazz
    @students = @clazz.students.sort_by do |student|
      user = student.user
      [user.last_name.downcase, user.first_name.downcase]
    end
    
    t = [
      'Class', 'First Name', 'Last Name', 'Date',
      'Step 1 pts', 'Step 1 max',
      'Rated R correct', 'Rated R answer-value', 'Rated R answer-unit', 'Rated R pts', 'Rated R max',
      'Rated T correct', 'Rated T answer', 'Rated T pts', 'Rated T max',
      'Step 2 pts', 'Step 2 max',
      'Measured R correct', 'Measured R answer-value', 'Measured R answer-unit', 'Measured R pts', 'Measured R max',
      'DMM conn pts', 'DMM conn max', 'Res conn pts', 'Res conn max',
      'Knob correct', 'Knob answer', 'Knob pts', 'Knob max',
      'Order pts', 'Order max',
      'Power pts', 'Power max',
      'Step 3 pts', 'Step 3 max',
      'T-range correct min', 'T-range correct max',
      'T-range answer min-value', 'T-range answer min-unit',
      'T-range answer max-value', 'T-range answer max-unit',
      'T-range pts', 'T-range max',
      'In/out correct', 'In/out answer', 'In/out pts', 'In/out max',
      'Step 4 (time) pts', 'Step 4 (time) max',
      'Time reading (s)', 'Time reading pts', 'Time reading max',
      'Time measuring (s)', 'Time measuring pts', 'Time measuring max',
      'Total pts', 'Total max'
    ].join(@@sep) << "\n"
    
    @students.each do |student|
      user = student.user
      
      learner = getLearner(@offering.id, student.id)
      mr = Saveable::Sparks::MeasuringResistance.find_by_learner_id(learner)
      reports = Saveable::Sparks::MeasuringResistanceReport.find_all_by_measuring_resistance_id(mr)
      reports.each do |r|
        log = JSON.parse(r.content)[0]
        section = log['sections'][0]
        questions = section['questions']
        result = JSON.parse(r.graded_result)
        root = result['root']
        toleranceAnswer = questions[1]['answer']
        toleranceAnswer = toleranceAnswer ? toleranceAnswer / 100.0 : 'Invalid'
        list = [@clazz.name, user.first_name, user.last_name,
          @template.time_str(@template.time_from_ms(log['start_time'])),
          root['reading']['points'],
          root['reading']['maxPoints'],
          questions[0]['correct_answer'],
          questions[0]['answer'],
          questions[0]['unit'],
          root['reading']['rated_r_value']['points'],
          root['reading']['rated_r_value']['maxPoints'],
          questions[1]['correct_answer'],
          toleranceAnswer,
          root['reading']['rated_t_value']['points'],
          root['reading']['rated_t_value']['maxPoints'],
          root['measuring']['points'],
          root['measuring']['maxPoints'],
          questions[2]['correct_answer'],
          questions[2]['answer'],
          questions[2]['unit'],
          root['measuring']['measured_r_value']['points'],
          root['measuring']['measured_r_value']['maxPoints'],
          root['measuring']['plug_connection']['points'],
          root['measuring']['plug_connection']['maxPoints'],
          root['measuring']['probe_connection']['points'],
          root['measuring']['probe_connection']['maxPoints'],
          result['optimal_dial_setting'],
          result['submit_dial_setting'],
          root['measuring']['knob_setting']['points'],
          root['measuring']['knob_setting']['maxPoints'],
          root['measuring']['task_order']['points'],
          root['measuring']['task_order']['maxPoints'],
          root['measuring']['power_switch']['points'],
          root['measuring']['power_switch']['maxPoints'],
          root['t_range']['points'],
          root['t_range']['maxPoints'],
          questions[3]['correct_answer'][0],
          questions[3]['correct_answer'][1],
          questions[3]['answer'][0],
          questions[3]['unit'][0],
          questions[3]['answer'][1],
          questions[3]['unit'][1],
          root['t_range']['t_range_value']['points'],
          root['t_range']['t_range_value']['maxPoints'],
          questions[4]['correct_answer'],
          questions[4]['answer'],
          root['t_range']['within_tolerance']['points'],
          root['t_range']['within_tolerance']['maxPoints'],
          root['time']['points'],
          root['time']['maxPoints'],
          result['reading_time'] / 1000,
          root['time']['reading_time']['points'],
          root['time']['reading_time']['maxPoints'],
          result['measuring_time'] / 1000,
          root['time']['measuring_time']['points'],
          root['time']['measuring_time']['maxPoints'],
          root['points'],
          root['maxPoints']
        ]
        t << list.join(@@sep) << "\n"
      end
    end
    
    csvFile = Tempfile.new('sparks-csv')
    csvFile.write(t)
    csvFile.close
    send_file(csvFile.path, { :filename => "#{@offering.name}.#{@clazz.name}.txt" })
  end
  
  def class_report
    #class, activity
    @offering = Portal::Offering.find_by_id(params[:offering_id])
    @clazz = @offering.clazz
    @students = @clazz.students
    render :template => 'sparks/report/measuring_resistance/class_report'
  end
  
  ## All historical data for a student
  def learner_report
    @offering = Portal::Offering.find(params[:offering_id])
    studentId = params[:student_id] || current_user.portal_student.id
    learner = getLearner(@offering.id, studentId)
    mr = Saveable::Sparks::MeasuringResistance.find_by_learner_id(learner)
    @reports = Saveable::Sparks::MeasuringResistanceReport.find_all_by_measuring_resistance_id(mr)
    render :template => 'sparks/report/measuring_resistance/learner_report'
  end
  
  ## Data for a single session of a student
  def learner_session_report
    @report = Saveable::Sparks::MeasuringResistanceReport.find_by_id(params[:id]);
    cookies[:report_id] = @report.id
    render :template => 'sparks/report/measuring_resistance/learner_session_report'
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
