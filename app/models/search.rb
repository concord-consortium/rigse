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
  attr_accessor :without_teacher_only
  attr_accessor :activity_page
  attr_accessor :investigation_page
  attr_accessor :per_page
  attr_accessor :user_id
  attr_accessor :include_contributed

  SearchableModels        = [Investigation, Activity, ResourcePage, ExternalActivity]
  InvestigationMaterial   = "Investigation"
  ActivityMaterial        = "Activity"
  AllMaterials            = [InvestigationMaterial, ActivityMaterial]

  Newest       = 'Newest'
  Oldest       = 'Oldest'
  Alphabetical = 'Alphabetical'
  Popularity   = 'Popularity'
  Score        = 'Score'
  SortOptions  = {
    Newest       => [:updated_at, :desc],
    Oldest       => [:updated_at],
    Alphabetical => [:name],
    Popularity   => [:offerings_count, :desc],
    Score        => [:score, :desc]
  }
  NoSearchTerm    = nil
  NoGradeSpan     = NoDomainID = AnyProbeType =[]
  NoProbeRequired = ["0"]

  def self.clean_search_terms (term)
    return NoSearchTerm unless term
    # http://rubular.com/r/0XlbltgfqY
    not_word_digit_or_space = /[^\w|\s]/
    term.gsub(not_word_digit_or_space,'')
  end

  def self.clean_domain_id(domain_id)
    return NoDomainID unless domain_id
    [domain_id].flatten
  end
  def self.clean_material_types(material_types)
    return AllMaterials if material_types.nil?
    return AllMaterials if material_types.empty?
    return AllMaterials if material_types.blank?
    return [material_types].flatten
  end

  def initialize(opts={})
    self.text           = Search.clean_search_terms(opts[:search_term])
    self.domain_id      = Search.clean_domain_id(opts[:domain_id])
    self.material_types = Search.clean_material_types(opts[:material_types])
    self.results        = {}
    self.hits           = {}
    self.no_probes      = false

    self.user_id        = opts[:user_id]

    self.engine         = opts[:engine]         || Sunspot
    self.grade_span     = opts[:grade_span]     || NoGradeSpan
    self.probe          = opts[:probe]          || AnyProbeType
    self.no_probes      = opts[:no_probe]       || false
    self.private        = opts[:private]        || false
    self.sort_order     = opts[:sort_order]     || Newest
    self.per_page       = opts[:per_page]       || 10

    self.activity_page        = opts[:activity_page]       || 1
    self.investigation_page   = opts[:investigation_page]  || 1
    self.include_contributed  = opts[:include_contributed] || false
    self.without_teacher_only = opts[:without_teacher_only]|| true
    self.search()
  end

  def search
    self.results[:all] = []
    self.hits[:all] = []
    self.material_types.each do |type|
      _results = self.engine.search(SearchableModels) do |s|
        s.fulltext(self.text)
        s.any_of do |c|
          c.with(:published, true)
          c.with(:published, [true, false]) if self.private
          c.with(:user_id, self.user_id)
        end
        s.with(:material_type, type)
        s.with(:domain_id, self.domain_id) unless self.domain_id.empty?
        s.with(:grade_span, self.grade_span) unless self.grade_span.empty?
        s.with(:probe_type_ids, self.probe) unless (self.probe.empty? || self.no_probes)
        s.with(:no_probes, true) if self.no_probes
        s.with(:is_official, true) unless self.include_contributed
        s.facet :material_type
        s.order_by(*SortOptions[self.sort_order])
        if (type==Search::ActivityMaterial)
          s.paginate(:page => self.activity_page, :per_page => self.per_page)
        elsif (type==Search::InvestigationMaterial)
          s.paginate(:page => self.investigation_page, :per_page => self.per_page)
        end
      end
      self.results[:all] += _results.results
      self.hits[:all]    += _results.hits
      self.results[type] = _results.results
      self.hits[type]    = _results.hits
    end
  end

  def params
    params = {}
    keys = [:user_id, :material_types, :grade_span, :probe, :private, :sort_order,
      :per_page, :include_contributed, :investigation_page, :activity_page]
    keys.each do |key|
      value = self.send key
      if value
        params[key] = value
      end
    end
    # TODO: remove coupled controller concerns from this:
    params.merge({:controller => 'search', :action => 'index'})
  end

  def types(*types)
    type_names = types.map { |t| t.name                           }
    self.results.select    { |r| type_names.include? r.class_name }
  end

  def count; self.hits.size; end
  alias_method :size, :count
  alias_method :len, :count

  alias_method :probe_type, :probe

  def investigation_checkedstatus; self.search.material_types.include? ::Investigation ; end
  def activity_checkedstatus; self.search.material_types.include? ::Activity ; end
  def external_activity_checkedstatus; self.search.material_types.include? ::Activity ; end
  def include_external_activities?; false; end

end