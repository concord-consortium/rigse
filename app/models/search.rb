class Search
  attr_accessor :engine
  attr_accessor :results
  attr_accessor :hits
  attr_accessor :text
  attr_accessor :material_types
  attr_accessor :order
  attr_accessor :private
  attr_accessor :probe_types

  AllMaterials = [Investigation, Activity]
  Newest       = [:updated_at, :desc]
  Oldest       = [:updated_at]
  Alphabetical = [:title]
  Popularity   = [:offerings_count, :desc]

  NoText       = nil

  def initialize(opts={})
    @results        = []
    @hits           = []

    @material_types = opts[:material_types] || AllMaterials
    @text           = opts[:text]           || NoText
    @engine         = opts[:engine]         || Sunspot
    @order          = opts[:order]          || Newest
    @private        = opts[:private]
    self.search()
  end

  def search
    _results = @engine.search(@material_types) do |s|
      s.fulltext(@text)
      s.with(:published, true) unless @private
      s.order_by(*@order)
    end
    self.results = _results.results
    self.hits    = _results.hits
  end

  def count; self.hits.size; end
  alias_method :size, :count
  alias_method :len, :count

end