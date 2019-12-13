# currently this model isn't backed by AR
# Its sole purpose is to clean up searching Report::Learner queries.

class Report::Learner::Selector
  attr_accessor :all_schools, :all_teachers, :all_runnables, :all_perm_forms,
                :select_schools, :select_teachers, :select_runnables, :select_perm_form,
                :start_date, :end_date, :hide_names,
                :learners


  def initialize(options, current_visitor)
    @learners = []
    @runnable_names = []

    # include the learners in the results, this flag also disables the aggregrations
    # by default it includes up to 5000 learners, but this can overridden with the
    # size_limit parameter
    options['show_learners'] = options['size_limit'].present? ?  options['size_limit'].to_i : 5000
    esResponse = API::V1::ReportLearnersEsController.query_es(options, current_visitor)
    hits = esResponse['hits']['hits']

    if hits && hits.size > 0
      ids = hits.map { |h| h['_id'] }
      @learners = Report::Learner.find(ids)
      @runnable_names = hits.map { |h| h['_source']['runnable_type_and_id'] }
      @runnable_names = @runnable_names.uniq
    end
  end

  def runnables_to_report_on
    @select_runnables = @runnable_names.map    { |r|
      case(r)
      when /^investigation_(\d+)/
        Investigation.find($1)
      when /^activity_(\d+)/
        ::Activity.find($1)
      when /^externalactivity_(\d+)/
        ExternalActivity.find($1)
      end
    }
    return @select_runnables
  end

end
