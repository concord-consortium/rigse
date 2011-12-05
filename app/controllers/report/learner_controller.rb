class Report::LearnerController < ApplicationController

  before_filter :setup


  def update_learners
    # this should be removed eventually,
    # force loading report-learner data
    Portal::Learner.all.each { |l| Report::Learner.for_learner(l).update_fields }
  end


  def setup
    # commit"=>"update learners"
    if params['commit'] =~ /update learners/i
      update_learners
    end
    @all_schools           = Portal::School.all.sort_by {|s| s.name}
    # TODO: fix me -- choose runnables better
    @all_runnables         = Investigation.published.sort_by { |i| i.name }

    @start_date            = params['start_date']
    @end_date              = params['end_date']

    @select_runnables      = params['runnables'] || []
    @select_schools        = params['schools']   || []

    # to populate dropdown menus:
    @select_schools   = @select_schools.map   { |s| Portal::School.find(s) }
    @select_runnables = @select_runnables.map { |r| Investigation.find(r)  }

    # helper model to limit learner selections:
    @learner_selector = Report::Learner::Selector.new({
                          :schools    => @select_schools.map  { |s| s.id},
                          :runnables  => @select_runnables.map{ |r| r.id},
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
      "Investigations:" => @select_learners.map {|l| l.runnable_id}.uniq.size
    }

    if params[:commit] == 'usage report'
      sio = StringIO.new
      report = Reports::Usage.new(:investigations => @select_runnables, :report_learners => @select_learners)
      report.run_report(sio)
      send_data(sio.string, :type => "application/vnd.ms.excel", :filename => "usage.xls" )
    end
  end


  def index
    # renders views/report/learner/index.html.haml
  end

end

