class Search
  attr_accessor :engine
  attr_accessor :results
  attr_accessor :hits
  attr_accessor :text
  attr_accessor :material_types
  attr_accessor :sort_order
  attr_accessor :private
  attr_accessor :probe_type
  attr_accessor :grade_span

  AllMaterials = [Investigation, Activity]
  Newest       = [:updated_at, :desc]
  Oldest       = [:updated_at]
  Alphabetical = [:title]
  Popularity   = [:offerings_count, :desc]

  NoSearchTerm = nil
  NoGradeSpan  = NoProbeType = []

  def initialize(opts={})
    debugger
    @results        = []
    @hits           = []

    @material_types = opts[:material_types] || AllMaterials
    @text           = opts[:search_term]    || NoSearchTerm
    @engine         = opts[:engine]         || Sunspot
    @sort_order     = opts[:sort_order]     || Newest
    @grade_span     = opts[:grade_span]     || NoGradeSpan
    @probe_type     = opts[:probe_type]     || NoProbeType
    @private        = opts[:private]
    self.search()
  end

  def search
    _results = @engine.search(AllMaterials) do |s|
      s.fulltext(@text)
      s.with(:published, true) unless @private
      # s.with(:material_type, material_types)
      # s.facet :material_type
      s.order_by(*@sort_order)
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