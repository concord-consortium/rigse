class Search
  attr_accessor :engine
  attr_accessor :results
  attr_accessor :hits
  attr_accessor :text
  attr_accessor :material_types
  attr_accessor :sort_order
  attr_accessor :private
  attr_accessor :probe
  attr_accessor :no_probes
  attr_accessor :grade_span
  attr_accessor :domain_id

  AllMaterials = [Investigation, Activity, ResourcePage, ExternalActivity]

  Newest       = 'Newest'
  Oldest       = 'Oldest'
  Alphabetical = 'Alphabetical'
  Popularity   = 'Popularity'
  SortOptions  = {
    Newest       => [:updated_at, :desc],
    Oldest       => [:updated_at],
    Alphabetical => [:name],
    Popularity   => [:offerings_count, :desc]
  }
  NoSearchTerm    = nil
  NoGradeSpan     = NoDomainID = AnyProbeType =[]
  NoProbeRequired = ["0"]

  def initialize(opts={})
    @results        = []
    @hits           = []
    @no_probes      = false
    @material_types = opts[:material_types] || AllMaterials
    @domain_id      = opts[:domain_id]      || NoDomainID
    @text           = opts[:search_term]    || NoSearchTerm
    @engine         = opts[:engine]         || Sunspot
    @grade_span     = opts[:grade_span]     || NoGradeSpan
    @probe          = opts[:probe]          || AnyProbeType
    @no_probes      = opts[:no_probe]       || false
    @private        = opts[:private]
    @sort_order     = opts[:sort_order]     || Newest
    self.search()
  end


  def parse_sort_order(sort_order)
    return SortOptions(sort_order) || [:updated_at, :desc]
  end

  def search
    _results = @engine.search(AllMaterials) do |s|
      s.fulltext(@text)
      s.with(:published, true) unless @private
      s.with(:material_type, @material_types)
      s.with(:domain_id, @domain_id) unless @domain_id.empty?
      s.with(:grade_span, @grade_span) unless @grade_span.empty?
      s.with(:probe_type_ids, @probe) unless (@probe.empty? || @no_probes)
      s.with(:no_probes, true) if @no_probes
      s.facet :material_type
      s.order_by(*SortOptions[@sort_order])
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