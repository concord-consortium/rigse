# currently this model isn't backed by AR
# Its sole purpose is to clean up searching Report::Learner queries.

class Report::Learner::Selector
  attr_accessor :all_schools, :all_teachers, :all_runnables, :all_perm_forms,
                :select_schools, :select_teachers, :select_runnables, :select_perm_form,
                :start_date, :end_date, :hide_names,
                :learners, :last_hit_sort_value


  def initialize(params, current_visitor, options={})
    @learners = []
    @runnable_names = []
    @last_hit_sort_value = nil
    include_runnable_and_learner = options.has_key?(:include_runnable_and_learner) && options[:include_runnable_and_learner]

    # include the learners in the results, this flag also disables the aggregrations
    # by default it includes up to 5000 learners, but this can overridden with the
    # size_limit parameter
    params['show_learners'] = params['size_limit'].present? ? params['size_limit'].to_i : 5000
    if (options.has_key?(:search_after))
      params['search_after'] = options[:search_after]
    end
    esResponse = API::V1::ReportLearnersEsController.query_es(params, current_visitor)
    hits = esResponse['hits']['hits']

    if hits && hits.size > 0
      ids = hits.map { |h| h['_id'] }
      @learners = include_runnable_and_learner ? Report::Learner.includes(:runnable, :learner).find(ids) : Report::Learner.find(ids)
      @runnable_names = hits.map { |h| h['_source']['runnable_type_and_id'] }
      @runnable_names = @runnable_names.uniq
      # every returned document will have a unique 'sort' value. This returns the last one.
      @last_hit_sort_value = hits.last['sort']
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
