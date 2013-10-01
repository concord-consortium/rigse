class Search
  attr_accessor :engine
  attr_accessor :results
  attr_accessor :hits
  attr_accessor :text
  attr_accessor :material_types
  attr_accessor :sort_order
  attr_accessor :private
  attr_accessor :probe
  attr_accessor :grade_span
  attr_accessor :domain_id

  AllMaterials = [Investigation, Activity, ResourcePage, ExternalActivity]
  Newest       = [:updated_at, :desc]
  Oldest       = [:updated_at]
  Alphabetical = [:title]
  Popularity   = [:offerings_count, :desc]

  NoSearchTerm = nil
  NoGradeSpan  = NoDomainID = NoProbeType =[]

  def initialize(opts={})
    @results        = []
    @hits           = []
    @material_types = opts[:material_types] || AllMaterials
    @domain_id      = opts[:domain_id]      || NoDomainID
    @text           = opts[:search_term]    || NoSearchTerm
    @engine         = opts[:engine]         || Sunspot
    @grade_span     = opts[:grade_span]     || NoGradeSpan
    @probe          = opts[:probe]          || NoProbeType
    @private        = opts[:private]
    @sort_order     = parse_sort_order(opts[:sort_order])
    self.search()
  end

  def parse_sort_order(sort_order)
    return Newest if sort_order.blank?
    return sort_order.split().map {|i| i.to_sym}
  end

  def search
    _results = @engine.search(AllMaterials) do |s|
      s.fulltext(@text)
      s.with(:published, true) unless @private
      s.with(:material_type, @material_types)
      s.with(:domain_id, @domain_id) unless @domain_id.empty?
      s.with(:grade_span, @grade_span) unless @grade_span.empty?
      s.with(:probe_type_ids, @probe) unless @probe.empty?
      s.facet :material_type
      # s.order_by(*@sort_order)
    end
    self.results        = _results.results
    self.hits           = _results.hits
  end

  def types(*types)
    type_names = types.map { |t| t.name                           }
    self.results.select    { |r| type_names.include? r.class_name }
  end

  def count; self.hits.size; end
  alias_method :size, :count
  alias_method :len, :count

end