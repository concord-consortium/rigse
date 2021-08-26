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
  attr_accessor :without_teacher_only
  attr_accessor :activity_page
  attr_accessor :investigation_page
  attr_accessor :interactive_page
  attr_accessor :collection_page
  attr_accessor :per_page
  attr_accessor :user_id
  attr_accessor :user
  attr_accessor :include_contributed
  attr_accessor :include_official
  attr_accessor :include_mine
  attr_accessor :include_templates
  attr_accessor :show_archived
  attr_accessor :material_properties
  attr_accessor :grade_level_groups
  attr_accessor :subject_areas
  attr_accessor :no_sensors
  attr_accessor :sensors
  attr_accessor :project_ids

  attr_accessor :available_subject_areas
  attr_accessor :available_grade_level_groups
  attr_accessor :available_projects
  attr_accessor :available_sensors
  attr_accessor :number_authored_resources

  attr_accessor :searchable_models

  InvestigationMaterial   = "Investigation"
  ActivityMaterial        = "Activity"
  InteractiveMaterial     = "Interactive"
  CollectionMaterial      = "Collection"
  AllMaterials            = [InvestigationMaterial, ActivityMaterial, InteractiveMaterial, CollectionMaterial]

  AllSearchableModels       = [ ExternalActivity, Interactive ]

  DefaultSearchableModels   = [ ExternalActivity ]



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

  def self.grade_level_groups
    { 'K-2' => ["K","1","2"], '3-4' => ["3","4"], '5-6' => ["5","6"], '7-8' => ["7","8"], '9-12' => ["9","10","11","12"], 'Higher Ed' => ["Higher Ed"] }
  end

  def self.clean_search_terms (term)
    return NoSearchTerm if (term.nil? || term.blank?)
    # http://rubular.com/r/ML9V9EMCKh (include apostrophe)
    not_valid_chars = /[-+]+/
    term.gsub(not_valid_chars,' ').strip
  end

  def user
    return nil unless self.user_id
    User.find(self.user_id)
  end

  def show_user_all_materials?
    user.has_role? ['admin']
  end

  def cohort_ids
    return nil unless self.user
    return nil unless self.user.portal_teacher
    return nil if self.user.portal_teacher.cohorts.empty?
    return self.user.portal_teacher.cohorts.map {|c| c.id}
  end

  def self.clean_material_types(material_types)
    return AllMaterials if material_types.nil?
    return AllMaterials if material_types.empty?
    return AllMaterials if material_types.blank?
    return [material_types].flatten
  end


  def initialize(opts={})

    #
    # If this is not a subclass, use the default models.
    #
    if self.class == Search
        self.searchable_models = DefaultSearchableModels
    end

    self.text                 = Search.clean_search_terms(opts[:search_term])
    self.clean_material_types = Search.clean_material_types(opts[:material_types])
    # Keep 'raw' value too, so the view can examine what was actually selected by user.
    # TODO: if we focus on this class more, I think it would be much better to move all the
    #       properties that are only used by form elements in view to a new, separate class.
    self.material_types              = opts[:material_types] || []
    self.grade_level_groups          = opts[:grade_level_groups] || []
    self.subject_areas               = opts[:subject_areas] || []
    self.project_ids                 = opts[:project_ids] || []
    self.sensors                     = opts[:sensors] || []
    self.available_subject_areas     = []
    self.available_projects          = []
    self.available_sensors           = []
    self.available_grade_level_groups = { 'K-2' => 0,'3-4' => 0,'5-6' => 0,'7-8' => 0,'9-12' => 0, 'Higher Ed' => 0 }
    self.number_authored_resources   = 0

    self.results        = {}
    self.hits           = {}
    self.total_entries  = {}

    self.user_id        = opts[:user_id]
    self.user           = User.find(self.user_id)  if self.user_id
    self.engine         = opts[:engine]         || Sunspot
    self.no_sensors     = opts[:no_sensors]     || false
    self.private        = opts[:private]        || false
    self.sort_order     = opts[:sort_order]     || Newest
    self.per_page       = opts[:per_page]       || 10

    self.activity_page        = opts[:activity_page]       || 1
    self.investigation_page   = opts[:investigation_page]  || 1
    self.interactive_page     = opts[:interactive_page]    || 1
    self.collection_page      = opts[:collection_page]     || 1
    self.without_teacher_only = opts[:without_teacher_only]|| true
    self.material_properties  = opts[:material_properties] || []
    self.include_contributed  = opts[:include_contributed] || false
    self.include_mine         = opts[:include_mine]        || false
    self.include_official     = opts[:include_official]    || false
    self.include_templates    = opts[:include_templates]   || false
    self.show_archived     = opts[:show_archived]    || false

    self.fetch_available_filter_options()

    #
    # Allow subclasses to add their own available search parameters
    #
    self.fetch_custom_search_params

    self.search() unless opts[:skip_search]
  end

  #
  # Subclasses can override this to set attributes
  # that clients might use to find available search parameters.
  #
  def fetch_custom_search_params; end

  def fetch_available_filter_options
    results = self.engine.search(self.searchable_models) do |s|
      s.facet :subject_areas
      s.facet :sensors
      s.facet :grade_levels do
        Search.grade_level_groups.each do |key, value|
          row(key) do
            with(:grade_levels, value)
          end
        end
      end
      s.facet :project_ids
      s.facet :user_id, :only => [self.user_id]
    end
    results.facet(:subject_areas).rows.each do |facet|
      self.available_subject_areas << facet.value
    end
    available_subject_areas.uniq!
    results.facet(:grade_levels).rows.each do |facet|
      self.available_grade_level_groups[facet.value] = 1
    end
    results.facet(:project_ids).rows.each do |facet|
      project = facet.instance
      if Pundit.policy!(user, project).visible?
        self.available_projects << {id: facet.value, name: project.name, landing_page_slug: project.landing_page_slug}
      end
    end
    available_projects.uniq!
    results.facet(:sensors).rows.each do |facet|
      self.available_sensors << facet.value
    end
    available_sensors.uniq!
    # Although the user_id facet will only ever return zero or one rows, the below 
    # seems like the most concise way to get the number of authored resources.
    results.facet(:user_id).rows.each do |facet|
      self.number_authored_resources += facet.count
    end
  end

  def search
    self.results[:all] = []
    self.hits[:all] = []
    self.total_entries[:all] = 0

    self.clean_material_types.each do |type|

      _results = self.engine.search(self.searchable_models) do |s|
        s.fulltext(self.text)
        # default list: published, plus all those authored by the current user
        s.any_of do |c|
          c.with(:published, true)
          c.with(:published, [true, false]) if self.private
          c.with(:user_id, self.user_id)
        end
        s.with(:user_id, self.user_id) if self.include_mine
        s.with(:material_type, type)

        search_by_sensors(s)
        search_by_authorship(s)
        search_by_material_properties(s)
        search_by_grade_levels(s)
        search_by_subject_areas(s)
        search_by_projects(s)
        search_without_assessments(s)

        s.with(:is_template, false) unless self.include_templates
        s.without(:is_archived, true) unless self.show_archived
        s.with(:is_archived, true) if self.show_archived

        if (!self.private && self.user_id)
          unless show_user_all_materials?
            s.any_of do |c|
              c.with(:cohort_ids, self.cohort_ids)
              c.with(:user_id, self.user_id)
              c.with(:cohort_ids, nil)
            end
          end
        end

        s.facet :material_type
        s.order_by(*SortOptions[self.sort_order])

        #
        # Allow subclasses to add filters
        #
        add_custom_search_filters(s)

        if (type == ActivityMaterial)
          s.paginate(:page => self.activity_page, :per_page => self.per_page)
        elsif (type == InvestigationMaterial)
          s.paginate(:page => self.investigation_page, :per_page => self.per_page)
        elsif (type == InteractiveMaterial)
          s.paginate(:page => self.interactive_page, :per_page => self.per_page)
        elsif (type == CollectionMaterial)
          s.paginate(:page => self.collection_page, :per_page => self.per_page)
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

  #
  # Subclasses can override this to add their own filters.
  #
  def add_custom_search_filters(search); end

  def types(*types)
    type_names = types.map { |t| t.name                           }
    self.results.select    { |r| type_names.include? r.class_name }
  end

  def requires_download
    self.material_properties.include? SearchModelInterface::RequiresDownload
  end

  def runs_in_browser
    self.material_properties.include? SearchModelInterface::RunsInBrowser
  end

  def will_show_official
    self.include_official
  end

  def will_show_contributed
    self.include_contributed
  end

  def search_by_authorship(search)
    return if !include_official && !include_contributed
    search.any_of do |c|
      # always show user's non-official work
      c.all_of do |c2|
        c2.with(:is_official, false)
        c2.with(:user_id, self.user_id)
      end
      if include_official || include_contributed
        c.with(:is_official, true)  if include_official
        c.with(:is_official, false) if include_contributed
      end
    end
  end

  def search_by_material_properties(search)
    return if (material_properties.size < 1)
    search.any_of do |s|
      material_properties.each do |r|
        # FIXME AU: Special-casing this seems hacky....
        if r == SearchModelInterface::RunsInBrowser
          s.without(:material_properties, SearchModelInterface::RequiresDownload)
        else
          s.with(:material_properties, r)
        end
      end
    end
  end

  def search_without_assessments(search)
    u = self.user
    if u.nil? or u.anonymous? or u.only_a_student?
      search.with(:is_assessment_item, false)
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

  def search_by_sensors(search)
    search.any_of do |s|
      s.with(:sensors, nil) if no_sensors
      s.with(:sensors).any_of(sensors) if sensors.present?
    end
  end

  def search_by_projects(search)
    return if project_ids.size < 1
    search.any_of do |s|
      project_ids.each do |g|
        s.with(:project_ids, g)
      end
    end
  end

  def count; self.hits.size; end
  alias_method :size, :count
  alias_method :len, :count

  def investigation_checkedstatus; self.material_types.include? ::Investigation ; end
  def activity_checkedstatus; self.material_types.include? ::Activity ; end
  def external_activity_checkedstatus; self.material_types.include? ::Activity ; end
  def include_external_activities?; false; end

end
