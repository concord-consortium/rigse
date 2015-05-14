class Search
  attr_accessor :engine
  attr_accessor :results
  attr_accessor :hits
  attr_accessor :total_entries
  attr_accessor :text
  attr_accessor :material_types
  attr_accessor :clean_material_types
  attr_accessor :sort_order
  attr_accessor :private
  attr_accessor :probe
  attr_accessor :no_probes
  attr_accessor :grade_span
  attr_accessor :domain_id
  attr_accessor :without_teacher_only
  attr_accessor :activity_page
  attr_accessor :investigation_page
  attr_accessor :interactive_page
  attr_accessor :per_page
  attr_accessor :user_id
  attr_accessor :include_contributed
  attr_accessor :include_official
  attr_accessor :include_mine
  attr_accessor :include_templates
  attr_accessor :java_requirements
  attr_accessor :grade_level_groups
  attr_accessor :subject_areas
  attr_accessor :projects
  attr_accessor :model_types
  attr_accessor :available_subject_areas
  attr_accessor :available_grade_level_groups
  attr_accessor :available_model_types 
  attr_accessor :available_projects

  SearchableModels        = [Investigation, Activity, ResourcePage, ExternalActivity, Interactive]
  InvestigationMaterial   = "Investigation"
  ActivityMaterial        = "Activity"
  InteractiveMaterial     = "Interactive"
  AllMaterials            = [InvestigationMaterial, ActivityMaterial, InteractiveMaterial]

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

  def self.grade_level_groups
    { 'K-2' => ["K","1","2"], '3-4' => ["3","4"], '5-6' => ["5","6"], '7-8' => ["7","8"], '9-12' => ["9","10","11","12"] }
  end

  def self.clean_search_terms (term)
    return NoSearchTerm if (term.nil? || term.blank?)
    # http://rubular.com/r/ML9V9EMCKh (include apostrophe)
    not_valid_chars = /[-+]+/
    term.gsub(not_valid_chars,' ').strip
  end

  def self.clean_domain_id(domain_id)
    return NoDomainID unless domain_id
    [domain_id].flatten
  end

  def self.cohorts_for(user_id)
    user = User.find(user_id)
    return nil unless user
    return nil unless user.portal_teacher
    return nil if user.portal_teacher.cohort_list.empty?
    return user.portal_teacher.cohort_list
  end

  def self.clean_material_types(material_types)
    return AllMaterials if material_types.nil?
    return AllMaterials if material_types.empty?
    return AllMaterials if material_types.blank?
    return [material_types].flatten
  end


  def initialize(opts={})
    self.text                 = Search.clean_search_terms(opts[:search_term])
    self.domain_id            = Search.clean_domain_id(opts[:domain_id])
    self.clean_material_types = Search.clean_material_types(opts[:material_types])
    # Keep 'raw' value too, so the view can examine what was actually selected by user.
    # TODO: if we focus on this class more, I think it would be much better to move all the
    #       properties that are only used by form elements in view to a new, separate class.
    self.material_types              = opts[:material_types] || []
    self.grade_level_groups          = opts[:grade_level_groups] || []
    self.subject_areas               = opts[:subject_areas] || []
    self.projects                    = opts[:projects] || []
    self.available_subject_areas      = []
    self.available_projects          = []
    self.available_grade_level_groups = { 'K-2' => 0,'3-4' => 0,'5-6' => 0,'7-8' => 0,'9-12' => 0 }
    self.model_types                 = opts[:model_types] || nil
    self.available_model_types       = []
    
    self.results        = {}
    self.hits           = {}
    self.total_entries  = {}
    self.no_probes      = false

    self.user_id        = opts[:user_id]

    self.engine         = opts[:engine]         || Sunspot
    self.grade_span     = opts[:grade_span]     || NoGradeSpan
    self.probe          = opts[:probe]          || AnyProbeType
    self.no_probes      = opts[:no_probes]      || false
    self.private        = opts[:private]        || false
    self.sort_order     = opts[:sort_order]     || Newest
    self.per_page       = opts[:per_page]       || 10

    self.activity_page        = opts[:activity_page]       || 1
    self.investigation_page   = opts[:investigation_page]  || 1
    self.interactive_page     = opts[:interactive_page]    || 1
    self.without_teacher_only = opts[:without_teacher_only]|| true
    self.java_requirements    = opts[:java_requirements]   || []
    self.include_contributed  = opts[:include_contributed] || false
    self.include_mine         = opts[:include_mine]        || false
    self.include_official     = opts[:include_official]    || false
    self.include_templates    = opts[:include_templates]   || false
    self.fetch_available_model_types()
    self.fetch_available_grade_subject_areas_projects()
    self.search() unless opts[:skip_search]
  end

  def fetch_available_model_types
    results = self.engine.search([Interactive]) do |s|
      s.facet :model_types
    end
    results.facet(:model_types).rows.each do |facet|
      self.available_model_types << facet.value
    end
  end
  
  def fetch_available_grade_subject_areas_projects
    results = self.engine.search([Investigation, Activity, ExternalActivity]) do |s|
      s.facet :subject_areas
      s.facet :grade_levels do 
        Search.grade_level_groups.each do |key, value|
          row(key) do
            with(:grade_levels, value)
          end
        end
      end
      s.facet :projects
    end
    results.facet(:subject_areas).rows.each do |facet|
      self.available_subject_areas << facet.value
    end
    available_subject_areas.uniq!
    results.facet(:grade_levels).rows.each do |facet|
      self.available_grade_level_groups[facet.value] = 1
    end
    results.facet(:projects).rows.each do |facet|
      self.available_projects << facet.value
    end
    available_projects.uniq!
  end

  def search
    self.results[:all] = []
    self.hits[:all] = []
    self.total_entries[:all] = 0
    self.clean_material_types.each do |type|
      _results = self.engine.search(SearchableModels) do |s|
        s.fulltext(self.text)
        s.any_of do |c|
          c.with(:published, true) unless self.include_mine
          c.with(:published, [true, false]) if self.private
          c.with(:user_id, self.user_id)
        end
        s.with(:material_type, type)
        s.with(:domain_id, self.domain_id) unless self.domain_id.empty?
        s.with(:grade_span, self.grade_span) unless self.grade_span.empty?

        search_by_probes(s)
        search_by_authorship(s)
        search_by_java_requirements(s)
        search_by_grade_levels(s)
        search_by_subject_areas(s)
        search_by_projects(s)
        s.with(:is_template, false) unless self.include_templates

        if (!self.private && self.user_id)
          s.any_of do |c|
            c.with(:cohorts, Search.cohorts_for(self.user_id))
            c.with(:cohorts, nil)
          end
        end

        s.facet :material_type
        s.order_by(*SortOptions[self.sort_order])
        if (type==Search::ActivityMaterial)
          s.paginate(:page => self.activity_page, :per_page => self.per_page)
        elsif (type==Search::InvestigationMaterial)
          s.paginate(:page => self.investigation_page, :per_page => self.per_page)
        elsif (type==Search::InteractiveMaterial)
		  search_by_model_types(s)
          s.paginate(:page => self.interactive_page, :per_page => self.per_page)
        end

      end
      self.results[:all] += _results.results
      self.hits[:all]    += _results.hits
      self.total_entries[:all] += _results.results.total_entries
      self.results[type] = _results.results
      self.hits[type]    = _results.hits
      self.total_entries[type] = _results.results.total_entries
    end
  end

  def params
    params = {}
    keys = [:user_id, :material_types, :grade_span, :probe, :private, :sort_order,
      :per_page, :include_contributed,:include_mine, :investigation_page, :activity_page, :java_requirements,
      :grade_level_groups, :subject_areas, :projects, :model_types]
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

  def requires_download
    self.java_requirements.include? SearchModelInterface::JNLPJavaRequirement
  end

  def runs_in_browser
    self.java_requirements.include? SearchModelInterface::NoJavaRequirement
  end

  def will_show_official
    self.include_official
  end

  def will_show_contributed
    self.include_contributed
  end

  def search_by_probes(search)
    return if !self.no_probes && self.probe.empty? # no sensor filter selected, nothing to do.
    search.any_of do |c|
      c.with(:no_probes, true) if self.no_probes
      c.with(:probe_type_ids, self.probe) unless (self.probe.empty?)
    end
  end

  def search_by_authorship(search)
    return if !include_official && !include_contributed
    search.any_of do |c|
      c.with(:is_official, true)  if include_official
      c.with(:is_official, false) if include_contributed
    end
  end

  def search_by_java_requirements(search)
    return if (java_requirements.size < 1)
    search.any_of do |s|
      java_requirements.each do |r|
        s.with(:java_requirements, r)
      end
    end
  end

  def search_by_grade_levels(search)
    return if grade_level_groups.size < 1
    search.any_of do |s|
      grade_level_groups.each do |g|
        s.with(:grade_levels, Search.grade_level_groups[g])
      end
    end
  end

  def search_by_subject_areas(search)
    return if subject_areas.size < 1
    search.any_of do |s|
      subject_areas.each do |g|
        s.with(:subject_areas, g)
      end
    end
  end

  def search_by_projects(search)
    return if projects.size < 1
    search.any_of do |s|
      projects.each do |g|
        s.with(:projects, g)
      end
    end
  end

  def search_by_model_types(search)
    return if model_types.nil? || model_types == "All"
    search.any_of do |s|
      s.with(:model_types, model_types)
    end
  end

  def count; self.hits.size; end
  alias_method :size, :count
  alias_method :len, :count

  alias_method :probe_type, :probe

  def investigation_checkedstatus; self.material_types.include? ::Investigation ; end
  def activity_checkedstatus; self.material_types.include? ::Activity ; end
  def external_activity_checkedstatus; self.material_types.include? ::Activity ; end
  def include_external_activities?; false; end

end