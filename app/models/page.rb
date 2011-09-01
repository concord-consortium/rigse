class Page < ActiveRecord::Base
  include JnlpLaunchable
  include Clipboard

  belongs_to :user
  belongs_to :section
  has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"

  has_one :activity, :through => :section

  # this could work if the finder sql was redone
  # has_one :investigation,
  #   :finder_sql => 'SELECT embeddable_data_collectors.* FROM embeddable_data_collectors
  #   INNER JOIN page_elements ON embeddable_data_collectors.id = page_elements.embeddable_id AND page_elements.embeddable_type = "Embeddable::DataCollector"
  #   INNER JOIN pages ON page_elements.page_id = pages.id
  #   WHERE pages.section_id = #{id}'

  has_many :page_elements, :order => :position, :dependent => :destroy
  has_many :inner_page_pages, :class_name => 'Embeddable::InnerPagePage'
  has_many :inner_pages, :class_name => 'Embeddable::InnerPage', :through => :inner_page_pages

  # The order of this array determines the order they show up in the Add menu
  # When adding new elements to the array, please place them alphebetically in the group.
  # The Biologica embeddables should all be grouped at the end of the list
  @@element_types = [
    Embeddable::DataTable,
    Embeddable::DrawingTool,
    Embeddable::DataCollector,
    Embeddable::ImageQuestion,
    Embeddable::InnerPage,
    Embeddable::MwModelerPage,
    Embeddable::MultipleChoice,
    Embeddable::NLogoModel,
    Embeddable::OpenResponse,
    Embeddable::Smartgraph::RangeQuestion,
    Embeddable::LabBookSnapshot, #displays as "Snapshot"
    Embeddable::SoundGrapher,
    Embeddable::Xhtml, #displays as "Text"
    Embeddable::VideoPlayer,
    Embeddable::Biologica::BreedOffspring,
    Embeddable::Biologica::Chromosome,
    Embeddable::Biologica::ChromosomeZoom,
    Embeddable::Biologica::MeiosisView,
    Embeddable::Biologica::MultipleOrganism,
    Embeddable::Biologica::Organism,
    Embeddable::Biologica::Pedigree,
    Embeddable::Biologica::StaticOrganism,
    Embeddable::Biologica::World,
    # BiologicaDna,
  ]

  if APP_CONFIG[:include_otrunk_examples]
    @@element_types << Embeddable::RawOtml
  end
  
  # @@element_types.each do |type|
  #   unless defined? type.dont_make_associations
  #     eval "has_many :#{type.to_s.tableize.gsub('/','_')}, :through => :page_elements, :source => :embeddable, :source_type => '#{type.to_s}'"
  #   end
  # end

  @@element_types.each do |klass|
    unless defined? klass.dont_make_associations
      eval "has_many :#{klass.name[/::(\w+)$/, 1].underscore.pluralize}, :class_name => '#{klass.name}',
      :finder_sql => 'SELECT #{klass.table_name}.* FROM #{klass.table_name}
      INNER JOIN page_elements ON #{klass.table_name}.id = page_elements.embeddable_id AND page_elements.embeddable_type = \"#{klass.to_s}\"
      WHERE page_elements.page_id = \#\{id\}'"
    end
  end

  delegate :saveable_types, :reportable_types, :to => :investigation

  has_many :raw_otmls, :through => :page_elements, :source => :embeddable, :source_type => 'Embeddable::RawOtml'

  has_many :teacher_notes, :as => :authored_entity
  has_many :author_notes, :as => :authored_entity
  include Noteable # convenience methods for notes...

  include Publishable

  acts_as_replicatable
  acts_as_list :scope => :section

  scope :like, lambda { |name|
    name = "%#{name}%"
    {
     :conditions => ["pages.name LIKE ? OR pages.description LIKE ?", name,name]
    }
  }

  include Changeable
  # validates_presence_of :name, :on => :create, :message => "can't be blank"

  accepts_nested_attributes_for :page_elements, :allow_destroy => true

  default_value_for :position, 1;
  default_value_for :description, ""

  send_update_events_to :investigation

  self.extend SearchableModel
  @@searchable_attributes = %w{name description}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

    # returns an array of class names transmogrified into the form
    # we use for dom-ids
    def paste_acceptable_types
      element_types.map {|t| t.name.underscore.clipboardify}
    end

    def element_types
      @@element_types
    end


    def search_list(options)
      name = options[:name]
      if (options[:include_drafts])
        pages = Page.like(name)
      else
        pages = Page.published.like(name)
      end
      portal_clazz = options[:portal_clazz] || (options[:portal_clazz_id] && options[:portal_clazz_id].to_i > 0) ? Portal::Clazz.find(options[:portal_clazz_id].to_i) : nil
      if portal_clazz
        pages = pages - portal_clazz.offerings.map { |o| o.runnable }
      end
      if options[:paginate]
        pages = pages.paginate(:page => options[:page] || 1, :per_page => options[:per_page] || 20)
      else
        pages
      end
    end
  end


  def page_number
    if (self.parent)
      index = self.parent.children.index(self)
      ## If index is nil, assume it's a new page
      return index ? index + 1 : self.parent.children.size + 1
    end
    0
  end

  def find_section
    case parent
      when Section
        return parent
      when Embeddable::InnerPage
        # kind of hackish:
        if(parent.parent)
          return parent.parent.section
        end
    end
    return nil
  end

  def find_activity
    if(find_section)
      return find_section.activity
    end
  end

  def default_page_name
    return "#{page_number}"
  end

  def name
    if self[:name] && !self[:name].empty?
      self[:name]
    else
      default_page_name
    end
  end

  def add_element(element)
    element.pages << self
    element.save
  end

  #
  # after_create :add_xhtml
  #
  # def add_xhtml
  #   if(self.page_elements.size < 1)
  #     xhtml = Embeddable::Xhtml.create
  #     xhtml.pages << self
  #     xhtml.save
  #   end
  # end

  #
  # return element.id for the component passed in
  # so for example, pass in an xhtml item in, and get back a page_elements object.
  # assumes that this page contains component.  Because this can cause confusion,
  # if we pass in a page_element we directly return that.
  def element_for(component)
    if component.instance_of? PageElement
      return component
    end
    return component.page_elements.detect {|pe| pe.embeddable.id == component.id }
  end

  def parent
    return self.inner_page_pages.size > 0 ? self.inner_page_pages[0].inner_page : section
  end

  include TreeNode


  def investigation
    activity = find_activity
    investigation = activity ? activity.investigation : nil
  end

  def has_inner_page?
    i_pages = page_elements.collect {|e| e.embeddable_type == Embeddable::InnerPage.name}
    if (i_pages.size > 0)
      return true
    end
    return false
  end

  def children
    # TODO: We should really return the elements
    # not the embeddable.  But it will require
    # careful refactoring... Not sure all the places
    # in the code where we expect embeddables to be returned.
    return page_elements.map { |e| e.embeddable }
  end


  #
  # Duplicate: try and create a deep clone of this page and its page_elements....
  # Esoteric question for the future: Would we ever want to clone the elements shallow?
  # maybe, but it will confuse authors
  #
  def duplicate
    @copy = self.deep_clone :no_duplicates => true, :never_clone => [:uuid, :updated_at,:created_at]
    @copy.name = "" # allow for auto-numbering of pages
    @copy.section = self.section
    @copy.save
    self.page_elements.each do |e|
      ecopy = e.duplicate
      ecopy.page = @copy
      ecopy.save
    end
    @copy.save
    @copy
  end

  # TODO: we have to make this container nuetral,
  # using parent / tree structure (children)
  def reportable_elements
    return @reportable_elements if @reportable_elements
    @reportable_elements = []
    unless teacher_only?
      @reportable_elements = page_elements.collect{|s| s.reportable_elements }.flatten
      @reportable_elements.each{|elem| elem[:page] = self}
    end
    return @reportable_elements
  end
end
