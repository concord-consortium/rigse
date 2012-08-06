class Report::LearnerController < ApplicationController

  include RestrictedController
  before_filter :setup
  before_filter :manager_or_researcher,
    :only => [
      :index,
      :update_learners
    ]

  def update_learners
    # this should be removed eventually,
    # force loading report-learner data
    Portal::Learner.all.each { |l| Report::Learner.for_learner(l).update_fields }
  end


  def setup
    @button_texts = {
      :apply => 'Apply Filters',
      :usage => 'Usage Report',
      :details => 'Details Report'
    }

    # commit"=>"update learners"
    if params['commit'] =~ /update learners/i
      update_learners
    end
    
    @all_schools           = Portal::School.has_teachers.all.sort_by  {|s| s.name.downcase}
    @all_teachers          = Portal::Teacher.all.sort_by {|t| t.name.downcase}

    # TODO: fix me -- choose runnables better
    # @all_runnables         = Investigation.published.sort_by { |i| i.name.downcase }
    @all_runnables         = Investigation.published + Investigation.assigned
    @all_runnables         = @all_runnables.uniq.sort_by { |i| i.name.downcase }

    @start_date            = params['start_date']
    @end_date              = params['end_date']

    begin
      Time.parse(@start_date)
    rescue
      @start_date = nil
    end

    @parsed_end_date = @end_date
    begin
      Time.parse(@end_date + " 23:59:59")
      @parsed_end_date += " 23:59:59"
    rescue
      @parsed_end_date = nil
      @end_date = nil
    end

    @select_runnables      = params['runnables'] || []
    @select_schools        = params['schools']   || []
    @select_teachers       = params['teachers']  || []

    # to populate dropdown menus:
    @select_schools   = @select_schools.map      { |s| Portal::School.find(s) }
    @select_teachers  = @select_teachers.map     { |t| Portal::Teacher.find(t) }
    @select_runnables = @select_runnables.map    { |r| Investigation.find(r)  }

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
                          :end_date   => @parsed_end_date
                        })

    # The learners we have selected:
    @select_learners  = @learner_selector.learners

    # some information to help researchers narrow search:
    @infos = {
      "learners:"       => @select_learners.size,
      "students:"       => @select_learners.map {|l| l.student_id}.uniq.size,
      "classes:"        => @select_learners.map {|l| l.class_id}.uniq.size,
      "Investigations:" => @select_learners.map {|l| l.runnable_id}.uniq.size
    }

    if params[:commit] == @button_texts[:usage]
      sio = StringIO.new
      runnables =  @select_runnables.size > 0 ? @select_runnables : @all_runnables
      report = Reports::Usage.new(:runnables => runnables, :report_learners => @select_learners, :blobs_url => dataservice_blobs_url, :include_child_usage => params[:include_child_usage])
      report.run_report(sio)
      send_data(sio.string, :type => "application/vnd.ms.excel", :filename => "usage.xls" )
    elsif params[:commit] == @button_texts[:details]
      sio = StringIO.new
      runnables =  @select_runnables.size > 0 ? @select_runnables : @all_runnables
      report = Reports::Detail.new(:runnables => runnables, :report_learners => @select_learners, :blobs_url => dataservice_blobs_url)
      report.run_report(sio)
      send_data(sio.string, :type => "application/vnd.ms.excel", :filename => "detail.xls" )
    end
  end

  def index
    # renders views/report/learner/index.html.haml
  end

end

