class Report::LearnerController < ApplicationController

  require 'cgi'

  before_filter :setup,
      :only => [
      :index,
      :logs_query,
      :update_learners
    ]

  protected

  def not_authorized_error_message
    super({resource_type: 'report learner'})
  end

  public

  def update_learners
    authorize Report::Learner
    Portal::Learner.all.each { |l| l.report_learner.update_fields }
  end

  def index
    authorize Report::Learner
    render layout: ENV['RESEARCHER_REPORT_ONLY'] ? "minimal" : "application"
  end

  def logs_query
    authorize Report::Learner
    @remote_endpoints = @select_learners.map { |l| l.learner.remote_endpoint_url(request.protocol, request.host_with_port) }
    render :layout => false
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
          render :text => text_response, :status => status
        end
        format.json do
          render :json => json_response, :status => status
        end
      end
    else
      render :nothing => true
    end
  end

  def report_only
    render layout: "minimal"
  end

  private

  def setup
    @button_texts = {
      :apply => 'Apply Filters',
      :usage => 'Usage Report',
      :details => 'Details Report',
      :arg_block => 'Arg Block Report',
      :logs_query => 'Log Manager Query',
      :log_manager => 'Open in Log Manager'
    }

    # commit"=>"update learners"
    if params[:commit] =~ /update learners/i
      update_learners
    elsif params[:commit] == @button_texts[:logs_query]
      # strip the commit=logs_query param so we don't have an infinite redirect,
      # but keep a valid commit param so we load the query data
      redirect_to learner_logs_query_path(request.GET.merge({:commit => true}))
      return
    end

    @no_log_manager = APP_CONFIG[:codap_url].nil? || APP_CONFIG[:log_manager_data_interactive_url].nil?

    if params.has_key?(:commit)
      # Selector makes a request to the Elasticsearch API and processes the results
      @learner_selector = Report::Learner::Selector.new(params, current_visitor)
      # The learners we have selected:
      @select_learners  = @learner_selector.learners
      @url_helpers = Reports::UrlHelpers.new(:protocol => request.protocol, :host_with_port => request.host_with_port)
      hide_names = params[:hide_names] == 'on'
    end

    hide_names = params[:hide_names] == 'on'

    if params[:commit] == @button_texts[:usage]
      sio = StringIO.new
      runnables =  @learner_selector.runnables_to_report_on
      report = Reports::Usage.new(:runnables => runnables, :report_learners => @select_learners, :blobs_url => dataservice_blobs_url, :include_child_usage => params[:include_child_usage], :url_helpers => @url_helpers, :hide_names => hide_names)
      report.run_report(sio)
      send_data(sio.string, :type => "application/vnd.ms.excel", :filename => "usage.xls" )
    elsif params[:commit] == @button_texts[:details]
      sio = StringIO.new
      runnables =  @learner_selector.runnables_to_report_on
      report = Reports::Detail.new(:runnables => runnables, :report_learners => @select_learners, :blobs_url => dataservice_blobs_url, :url_helpers => @url_helpers, :hide_names => hide_names)
      report.run_report(sio)
      send_data(sio.string, :type => "application/vnd.ms.excel", :filename => "detail.xls" )
    elsif params[:commit] == @button_texts[:arg_block]
      arg_block(@select_learners)
    elsif params[:commit] == @button_texts[:log_manager]
      log_manager
    end

  end

  def log_manager
    if @no_log_manager
      alert_and_reload "This portal is not configured to open the Log Manager"
      return
    end

    if @select_learners.length == 0
      alert_and_reload "No learners meet the criteria you selected"
      return
    end

    codap_url = APP_CONFIG[:codap_url]
    data_interactive_url = APP_CONFIG[:log_manager_data_interactive_url]

    # We'll let the Log Manager construct the query on run_remote_endpoint. In
    # order to do so, we provide the appropriate prefix for
    # run_remote_endpoints, and all the ids In the interest of URL-length
    # sanity, the ids are passed as a single string, joined by a delimiter
    # ('-') that is not percent encoded. (The practical URL length limit is
    # ~2k characters, so this should allow querying several hundred learners
    # before requests start failing because the URL is too long.)

    sample_learner_id = @select_learners.first.learner_id
    prefix = external_activity_return_url(sample_learner_id).match("(.*)" + sample_learner_id.to_s)[1]
    learner_ids = @select_learners.map { |l| l.learner_id }

    redirect_to(codap_url + "?moreGames=" + CGI::escape([{
      :name => "LogMgr",
      :dimensions => {
        :width => 600,
        :height => 800
      },
      :url => data_interactive_url + "?" + { :rep => prefix, :ids => learner_ids.join('-') }.to_param
    }].to_json))
  end

  def arg_block(learners)
    authoring_sites = learners.select { |l| l.runnable_type == "ExternalActivity" }.map do |learner|
      uri = URI(learner.runnable.url)
      "#{uri.scheme}://#{uri.host}:#{uri.port}"
    end

    learners = learners.reject { |l| l.permission_forms.strip.empty? }

    if learners.length == 0
      alert_and_reload "No learners with signed permission forms meet the criteria you selected"
      return
    end

    if authoring_sites.length == 0
      alert_and_reload "None of the selected learners performed external activities"
      return
    end

    # TODO: instead of refusing the request, modify the arg_block_bouncer to contain a list of the selected
    # authoring sites, with a submit button for each site (and disable the javascript auto-submit)
    if authoring_sites.uniq.count > 1
      alert_and_reload "The selected learners' arg block activity occurred on more than one authoring site. Try limiting your request to activities hosted on just one authoring site."
      return
    end

    @report_url = "#{authoring_sites.first}/c_rater/argumentation_blocks/report"
    @remote_endpoints = learners.map do |learner|
      learner.learner.remote_endpoint_url(request.protocol, request.host_with_port)
    end

    # intentionally leave out student name - results should be semi-anonymized
    columns = [:permission_forms, :teachers_name, :school_name, :class_name, :class_id, :student_id, :remote_endpoint]
    sort_by_indices = [:teachers_name, :school_name, :class_id, :student_id].map { |key| columns.find_index(key) }

    rows = learners.map do |learner|
      columns.map do |column|
        # except for remote_endpoint, column names are just names of Report::Learner instance methods
        column == :remote_endpoint ? learner.learner.remote_endpoint_url(request.protocol, request.host_with_port) : learner.send(column)
      end
    end

    remote_endpoint_index = columns.find_index(:remote_endpoint)

    # Several Report::Learners may correspond to the same (student, class, school) combination. We want to emit
    # one row per (student, class, school) combination, with the entry in the :remote_endpoint column being
    # an array of all remote_endpoints corresponding to that row. (remote_endpoints are 1:1 with Report::Learners)
    group_by_indices = columns.reject { |column| column == :remote_endpoint }.map { |key| columns.find_index(key) }
    remote_endpoints_by_row = rows.group_by { |row| row.values_at(* group_by_indices) }
    remote_endpoints_by_row.keys.each do |key|
      remote_endpoints_by_row[key] = remote_endpoints_by_row[key].map do |row|
        row[remote_endpoint_index]
      end
    end

    rows = remote_endpoints_by_row.keys.map {|key| key + [remote_endpoints_by_row[key]]}
    rows = rows.sort_by! { |row| row.values_at(* sort_by_indices) }

    @arg_block_buckets = {
      :columns => columns,
      :rows => rows
    }

    render :arg_block_bouncer, :layout => false
  end

  def alert_and_reload(message)
    flash[:alert] = message
    redirect_to request.GET.except(:commit)
  end

end
