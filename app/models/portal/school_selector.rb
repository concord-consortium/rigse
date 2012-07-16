class Portal::SchoolSelector
  USA = "United States"
  NO_STATE = "XX"  # db field width is 2 chars. :
  CHOICES_FILE = File.join(Rails.root, "resources", "country_list.txt")
  @@country_choices = nil

  attr_accessor :country          # string eg "United States"
  attr_accessor :state            # string eg "MA"
  attr_accessor :district         # int AR eg 212
  attr_accessor :district_name    # string
  attr_accessor :school           # int AR eg 212
  attr_accessor :school_name      # string
  attr_accessor :previous_attr    # hash old values
  attr_accessor :use_default_school
  def self.country_choices
    return @@country_choices if (@@country_choices && (! @@country_choices.empty?))
    @@country_choices = []
    File.open(CHOICES_FILE, "r:UTF-8") do |infile|
      while(line = infile.gets)
        @@country_choices.push line.strip.titlecase
      end
    end
    return @@country_choices
  end

  def initialize(params)
    params = params['school_selector'] if params['school_selector']
    params = params.reject { |k,v| v.nil? || v.empty? || v.blank? }
    params.each_pair do |attribute, value|
      self.set_attr(attribute,value)
    end
    self.load_previous_attributes
    self.validate
    self.record_previous_attributes
  end

  def load_previous_attributes
    # convert @previous_attr to hash from string
    return if @previous_attr.nil? or @previous_attr.empty?
    array = Base64.decode64(@previous_attr).split("|")
    @previous_attr = {
      :country  => array[0],
      :state    => array[1],
      :district => array[2] || nil, # 0 == nil for our purposes
      :school   => array[3] || nil  # 0 == nil for our purposes
    }
  end

  def record_previous_attributes
    attrs          = [@country, @state]
    district_id    = @district.id if @district
    district_id  ||= 0
    school_id      = @school.id if @school
    school_id    ||= 0

    attrs << district_id.to_s
    attrs << school_id.to_s
    @previous_attr =  Base64.encode64(attrs.join("|"))
  end


  def attr_changed?(symbol)
    return false unless @previous_attr
    return true if (self.send(symbol) != @previous_attr[symbol])
    return false
  end

  def get_attr(attr)
    get_method = attr.to_sym
    if self.respond_to? get_method
      return self.send get_method
    end
    return nil
  end

  def set_attr(attr,val)
    assigment_method = "#{attr}=".to_sym
    if self.respond_to? assigment_method
      self.send(assigment_method, val)
    end
  end

  def clear_attr(attr)
    self.set_attr(attr,nil)
  end

  def clear_choices(attr)
    @choices[attr] = []
  end

  def validate
    @needs   = nil
    @choices = {}
    previous_change = false
    attr_order.each do |attr|
      changed = attr_changed?(attr)
      choice_method = "#{attr.to_s}_choices".to_sym
      self.set_attr(attr,nil) if previous_change
      @needs ||= attr unless validate_attr(attr)
      @choices[attr] = (self.send(choice_method) || [])
      previous_change ||= changed
    end
    if self.use_default_school
      self.school = Portal::School.first
      @needs = nil
    end
  end

  def invalid?
    return !valid
  end

  def valid?
    return @needs == nil
  end

  def validate_attr(symbol)
    validation_method = "validate_#{symbol.to_s}"
    if self.respond_to? validation_method
      return self.send validation_method
    else
      return !self.send(symbol).nil?
    end
  end

  def validate_country
    @country ||= USA
    return true
  end

  def validate_state
    if @country != USA
      @state = default_state_for(@country)
      return true
    end
    return state_choices.include? @state
  end

  def validate_district
    return true if add_district
    if @district && (@district.kind_of? String)
      @district = Portal::District.find(@district)
    end
    if @country != USA
      @district = default_district_for(@country)
      return true
    end
    return false unless @district.kind_of? Portal::District
    # ensure that the district is in our list of districts.
    return district_choices.map {|d| d[1] }.include? @district.id
  end

  def validate_school
    return true if add_school
    if @school && (@school.kind_of? String)
      @school = Portal::School.find(@school)
    end
    return false unless @school.kind_of? Portal::School
    return school_choices.map { |s| s[1] }.include? @school.id
  end

  # def default_district
  #   return Portal::District.default
  # end

  def default_state_for(country)
    return NO_STATE
  end

  def default_district_for(state_or_country)
    Portal::District.find_by_similar_name_or_new("default district for #{state_or_country}")
  end


  def add_district
    return add_portal_resource(:district)
  end

  def add_school
    return add_portal_resource(:school)
  end

  # Attempt to add a new portal resource (school or district)
  # return true if successfully created / found
  def add_portal_resource(symbol)
    attribute_name = get_attr("#{symbol}_name")
    attribute = get_attr(symbol)
    portal_clazz = "Portal::#{symbol.to_s.capitalize}".constantize
    if self.allow_teacher_creation(symbol)
      if attribute_name && (!attribute_name.blank?)
        find_attributes = {:name => attribute_name}
        if @district && (@district.kind_of? Portal::District)
          find_attributes[:district_id] = @district.id
        end
        attribute = portal_clazz.find_by_similar_or_new(find_attributes,'registration')
        if attribute.new_record?
          # TODO: We should probably shouldn't create new
          # records if there isn't a current user ...
          attribute.state = @state
          attribute.save
        end
        set_attr(symbol,attribute) 
        return !attribute.nil?
      end
    end
    return false
    return false if @school.nil?
  end

  def needs
    return @needs
  end

  def choices(symbol=nil)
    return @choices[symbol] if symbol
    return @choices
  end


  def country_choices
    return Portal::SchoolSelector.country_choices
  end

  def state_choices
    if @country == USA
      return Portal::StateOrProvince.from_districts
    end
    return []
  end

  def district_choices
    if @state
      districts = Portal::District.find(:all, :conditions => {:state => @state })
      return districts.sort{ |a,b| a.name <=> b.name}.map { |d| [d.name, d.id] }
    end
    # return [default_district].map { |d| [d.name, d.id] }
    return []
  end


  def school_choices
    if @district && (@district.kind_of? Portal::District)
      schools = Portal::School.find(:all, :conditions => {:district_id => @district.id })
      return schools.sort{ |a,b| a.name <=> b.name}.map { |s| [s.name, s.id] }
    end
  end

  def select_args(field)
    value = self.send field
    if value && (value.respond_to? :id)
      value = value.id
    end
    return [:school_selector, field, self.choices[field] || [], {:selected => value, :include_blank => true}]
  end


  def attr_order
    [:country,:state,:district,:school]
  end

  def allow_teacher_creation(field=:school)
    acceptable_fields = []
    if self.country  == USA
      acceptable_fields << [:district] if self.state
    else
      acceptable_fields << [:district] if self.country
    end
    acceptable_fields << :school if self.district
    Admin::Project.default_project.allow_adhoc_schools && acceptable_fields.include?(field)
  end
end
