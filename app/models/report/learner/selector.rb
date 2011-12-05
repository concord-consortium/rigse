# currently this model isn't backed by AR
# Its sole purpose is to clean up searching Report::Learner queries.

class Report::Learner::Selector

  def initialize(options)
    # reject zero length strings and arrays
    options.reject! { |k,v| v.size < 1 if v.respond_to? :size }

    @scopes = {}

    @scopes[:in_schools]     = options[:schools]    if options[:schools]
    @scopes[:with_runnables] = options[:runnables]  if options[:runnables]

    @scopes[:before]         = Time.parse(options[:end_date])   if options[:end_date]
    @scopes[:after]          = Time.parse(options[:start_date]) if options[:start_date]
    
    if @scopes.size > 0
      results = Report::Learner
      @scopes.each_pair do |k,v|
        results = results.send(k,v)
      end
      @learners = results
    else
      @learners = Report::Learner.all
    end
  end

  def learners
    return @learners
  end
end

