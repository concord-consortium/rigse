class Report::LearnerController < ApplicationController

  include RestrictedController
  before_filter :manager_or_researcher,
    :only => [
      :index
    ]
  before_filter :setup

  def setup
    @all_schools           = Portal::School.all.sort_by  {|s| s.name.downcase}
    @all_teachers          = Portal::Teacher.all.sort_by {|t| t.name.downcase}

    # TODO: fix me -- choose runnables better
    @all_runnables         = Assignable.all_assignables.sort_by { |i| i.name.downcase }
    @all_runnables_by_id   = @all_runnables.group_by {|r| "#{r.class.to_s}|#{r.id}" }

    @start_date            = params['start_date']
    @end_date              = params['end_date']

    @select_runnables      = params['runnables'] || []
    @select_schools        = params['schools']   || []
    @select_teachers       = params['teachers']  || []

    @select_schools   = @select_schools.map      { |s| Portal::School.find(s) }
    @select_teachers  = @select_teachers.map     { |t| Portal::Teacher.find(t) }
    @select_runnables = @select_runnables.map    { |r|
      begin
        klass, id = r.split('|')
        klass.constantize.find(id)
      rescue
        nil
      end
    }.compact

    if (@select_schools.size > 0) 
      @all_teachers = @all_teachers.select       { |t| @select_schools.map{|s| s.teachers}.flatten.include? t  }
      @select_teachers = @select_teachers.select { |t| @select_schools.map{|s| s.teachers}.flatten.include? t  }
    end


    # helper model to limit learner selections:
    @learner_selector = Report::Learner::Selector.new({
                          :schools    => @select_schools,
                          :teachers   => @select_teachers,
                          :runnables  => @select_runnables,
                          :start_date => @start_date,
                          :end_date   => @end_date
                        })

    # The learners we have selected:
    @select_learners  = @learner_selector.learners

    # some information to help researchers narrow search:
    @infos = {
      "learners:"       => @select_learners.size,
      "students:"       => @select_learners.map {|l| l.student_id}.uniq.size,
      "classes:"        => @select_learners.map {|l| l.class_id}.uniq.size,
      "assignables:"    => @select_learners.map {|l| l.runnable_id}.uniq.size
    }

    # Because of issues with the spreadsheet gem and dealing with large workbooks (too many sheets, or too many cells within a sheet)
    # narrow down the applicable runnables, so the report only shows runnables that have learners
    if @select_runnables.size > 0
      runnables = @select_runnables
    else
      runnables = @select_learners.map{|l| @all_runnables_by_id["#{l.runnable_type}|#{l.runnable_id}"] }.flatten.uniq.compact
    end

    begin
      if params[:commit] == 'usage report'
        sio = StringIO.new
        report = Reports::Usage.new(:runnables => runnables, :report_learners => @select_learners, :blobs_url => dataservice_blobs_url)
        report.run_report(sio)
        send_data(sio.string, :type => "application/vnd.ms.excel", :filename => "usage.xls" )
      elsif params[:commit] == 'details report'
        sio = StringIO.new
        report = Reports::Detail.new(:runnables => runnables, :report_learners => @select_learners, :blobs_url => dataservice_blobs_url, :verbose => true)
        report.run_report(sio)
        send_data(sio.string, :type => "application/vnd.ms.excel", :filename => "detail.xls" )
      elsif params[:commit] == 'career stem report'
        sio = StringIO.new
        report = Reports::ConcludingCareerStem.new(:runnables => runnables, :report_learners => @select_learners, :blobs_url => dataservice_blobs_url, :verbose => true)
        report.run_report(sio)
        send_data(sio.string, :type => "application/vnd.ms.excel", :filename => "career_stem.xls" )
      end
    rescue Reports::Errors::GeneralReportError => e
      msg = "There was a problem running your report.\n\n"
      case e
      when Reports::Errors::TooManyCellsError
        msg += "You have too many total cells. Add filters to reduce the number of learners."
      when Reports::Errors::TooManySheetsError
        msg += "You have too many assignables selected. Add filters to reduce the number of assignables."
      else
        msg += "An Unknown error occurred. Try adding more filters to reduce the complexity of the report."
      end
      flash[:error] = msg.gsub("\n","<br/>\n")
    end
  end

  def index
    # renders views/report/learner/index.html.haml
  end

end

