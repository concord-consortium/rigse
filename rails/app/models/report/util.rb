class Report::Util
  ## FIXME Eventually this could use a service like memcached and then it wouldn't bloat the rails server processes

  ## 60 reports' details should be ok to hold in memory, for now
  MAX_CACHED_REPORTS = 60
  TRIM_BY = 10

  attr_accessor :offering, :learners
  attr_accessor :page_elements
  # attr_accessor :saveables
  attr_accessor :saveables_by_embeddable
  # attr_accessor :saveables_by_type, :saveables_by_learner_id, :saveables_by_answered, :saveables_by_correct
  # attr_accessor :embeddables, :embeddables_by_type
  attr_accessor :last_accessed

  cattr_accessor :cache

  @@cache = {}

  def self.factory(offering, show_only_active_learners = true, skip_filters = false)
    maintenance
    ## TODO This class should probably be thread-safe eventually
    @@cache[offering] ||= Report::Util.new(offering, show_only_active_learners, skip_filters)
    return @@cache[offering]
  end

  def self.reload(offering)
    invalidate(offering)
    return factory(offering)
  end

  def self.reload_without_filters(offering)
    invalidate(offering)
    return factory(offering, true, true)
  end

  def self.invalidate(offering)
    @@cache.delete(offering)
  end

  def self.maintenance
    if @@cache.size > MAX_CACHED_REPORTS
      puts "Cache size is #{@@cache.size}. Trimming down."
      last_time = @@cache.values.sort_by{|v| v.last_accessed}[TRIM_BY].last_accessed
      @@cache.delete_if{|k,v| v.last_accessed < last_time }
      puts "Cache size is now #{@@cache.size}."
    end
  end

  def saveable(learner, embeddable)
    results = saveables(:learner => learner, :embeddable => embeddable)
    results = [Saveable::SaveableStandin.new(embeddable)] if ( results.size < 1 )
    warn("found #{results.size} saveables for #{learner} : #{embeddable}") if ( results.size > 1 )
    return results.first
  end

  def saveables(options = {})
    @last_accessed = Time.now
    results = @saveables
    results = Array(@saveables_by_learner_id[options[:learner].id]) if options[:learner]
    results = results & Array(@saveables_by_answered[true]) if options[:answered]
    results = results & Array(@saveables_by_embeddable[options[:embeddable]]) if options[:embeddable]
    if options[:embeddables]
      embeddables = options[:embeddables]
      results = results & embeddables.map { |e| @saveables_by_embeddable[e]}.flatten
    end
    results = results & Array(@saveables_by_correct[true]) if options[:correct]
    results = results & Array(@saveables_by_submittted[true]) if options[:submitted]
    return results
  end

  def embeddables(options = {})
    @last_accessed = Time.now
    results = @embeddables
    results = Array(@embeddables_by_type[options[:type].to_s]) if options[:type.to_s]
    return results
  end

  def initialize(offering_or_learner, show_only_active_learners=false, skip_filters=false)
    @last_accessed = Time.now
    if offering_or_learner.kind_of?(Portal::Learner)
      @offering = offering_or_learner.offering

      @learners = [offering_or_learner]
    else
      @offering = offering_or_learner

      @learners = @offering.learners
      @learners = @learners.select{|l| l.bundle_logger.bundle_contents.count > 0 || l.saveable_count > 0 } if show_only_active_learners
    end

    @report_embeddable_filter = @offering.report_embeddable_filter
    unless (@report_embeddable_filter)
      @report_embeddable_filter = Report::EmbeddableFilter.create(:offering => @offering, :embeddables => [])
      @offering.reload
    end

    assignable = @offering.runnable
    if assignable.is_a?(ExternalActivity) && assignable.template
      assignable = assignable.template
    end

    @saveables               = []
    @saveables_by_type       = {}
    @saveables_by_learner_id = {}
    @saveables_by_embeddable = {}
    @saveables_by_correct    = {}
    @saveables_by_answered   = {}
    @saveables_by_submittted = {}

    reportables          = assignable.reportable_elements

    ## FIXME filtering of embeddables should happen here
    unless skip_filters
      results = @report_embeddable_filter.filter(results)
      allowed_embeddables = @report_embeddable_filter.embeddables
      if ! @report_embeddable_filter.ignore && allowed_embeddables.size > 0
        reportables = reportables.select{|r| allowed_embeddables.include?(r[:embeddable]) }
      end
    end

    elements             = reportables.map       { |r| r[:element]    }
    @embeddables         = reportables.map       { |r| r[:embeddable] }
    @embeddables_by_type = @embeddables.group_by { |e| e.class.to_s   }

    activity_lambda = lambda { |e| e[:activity] }
    section_lambda  = lambda { |e| e[:section]  }
    page_lambda     = lambda { |e| e[:page]     }
    lambdas = []
    if assignable.is_a? Investigation
      lambdas = [activity_lambda, section_lambda, page_lambda]
    elsif assignable.is_a? Activity
      lambdas = [section_lambda, page_lambda]
    elsif assignable.is_a? Page
      lambdas = [page_lambda]
    end

    @page_elements  = reportables.extended_group_by(lambdas)

    ResponseTypes.saveable_types.each do |type|
      all = []
      if @learners.size == 1
        all = type.where(learner_id: @learners[0].id)
      else
        all = type.where(offering_id: @offering.id)
      end
      @saveables += all
      @saveables_by_type[type.to_s] = all
    end
    # If an investigation has changed, and saveable elements have been removed (eek!)
    assignable_embeddables = assignable.page_elements.map{|pe|pe.embeddable}
    current_embeddables = assignable_embeddables
    current =  @saveables.select { |s| current_embeddables.include? s.embeddable}
    old = @saveables - current
    if old.size > 0
      warning = "WARNING: missing #{old.size} removed reportables in report for #{assignable.name}"
      Rails.logger.info(warning)
      @saveables = current
    end
    @saveables_by_answered   = @saveables.group_by { |s| s.answered?  }
    @saveables_by_learner_id = @saveables.group_by { |s| s.learner_id }
    @saveables_by_embeddable = @saveables.group_by { |s| s.embeddable }
    @saveables_by_correct    = @saveables.group_by { |s| (s.respond_to? 'answered_correctly?') ? s.answered_correctly? : false }
    @saveables_by_submittted = @saveables.group_by { |s| s.submitted? }
  end

  def complete_number(learner,activity = nil)
    if activity
      return saveables(:learner => learner, :embeddables => activity.reportable_elements.map { |r| r[:embeddable]}).size
    end
    return saveables(:learner => learner).size
  end

  def complete_percent(learner,activity = nil)
    completed = Float(complete_number(learner,activity))
    if activity
      total = Float(activity.reportable_elements.map { |r| r[:embeddable]}.size)
    else
      total = Float(embeddables.size)
    end
    return total < 0.5 ? 0.0 : (completed/total) * 100.0
  end

  def answered_number(learner)
    return saveables(:learner => learner, :answered => true).size
  end

  def correct_number(learner)
    return saveables(:learner => learner, :correct => true).size
  end

  def correct_percent(learner)
    correct = Float(correct_number(learner))
    #total = Float(embeddables.size)
    total = Float( embeddables.select { |e| e.respond_to? 'correctable?' }.size )
    return total < 0.5 ? 0.0 : (correct/total) * 100.0
  end
end
