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
    Portal::Learner.all.each { |l| l.report_learner.update_fields }
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

    # helper model to limit learner selections:
    @learner_selector = Report::Learner::Selector.new(params)

    # The learners we have selected:
    @select_learners  = @learner_selector.learners

    # some information to help researchers narrow search:
    # we might be able to speed this up by doing:
    # @select_learners.select("count(distinct student_id) AS 'student_count', " +
    #                         "count(distinct class_id) AS 'class_count', " +
    #                         "count(distinct runnable_id) AS 'runnable_count'")
    # note the last one should be a separate query that groups by runnable_type and counts that grouping
    @infos = {
      "learners:"       => @select_learners.size,
      "students:"       => @select_learners.map {|l| l.student_id}.uniq.size,
      "classes:"        => @select_learners.map {|l| l.class_id}.uniq.size
    }
    @select_learners.map {|l| l.runnable_type}.uniq.each{|runnable_type|
      @infos[runnable_type.pluralize + ":"] = @select_learners.select{|l| l.runnable_type == runnable_type}.map{|l| l.runnable_id}.uniq.size
    }

    if params[:commit] == @button_texts[:usage]
      sio = StringIO.new
      runnables =  @learner_selector.runnables_to_report_on
      report = Reports::Usage.new(:runnables => runnables, :report_learners => @select_learners, :blobs_url => dataservice_blobs_url, :include_child_usage => params[:include_child_usage])
      report.run_report(sio)
      send_data(sio.string, :type => "application/vnd.ms.excel", :filename => "usage.xls" )
    elsif params[:commit] == @button_texts[:details]
      sio = StringIO.new
      runnables =  @learner_selector.runnables_to_report_on
      report = Reports::Detail.new(:runnables => runnables, :report_learners => @select_learners, :blobs_url => dataservice_blobs_url)
      report.run_report(sio)
      send_data(sio.string, :type => "application/vnd.ms.excel", :filename => "detail.xls" )
    end
  end

  def index
    # renders views/report/learner/index.html.haml
  end
  
  def updated_at
    learner = Report::Learner.find_by_user_id_and_offering_id(current_visitor.id,params[:id])
    if learner
      modification_time = learner.last_run.strftime("%s")
      respond_to do |format|
        format.html do
          render :text => modification_time
        end
        format.json do
          render :json => {:modification_time => modification_time }
        end
      end
   
    else 
      render :nothing => true
    end
  end

end

