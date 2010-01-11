class Page < ActiveRecord::Base
  belongs_to :user
  belongs_to :section

  has_one :activity, :through => :section

  # this could work if the finder sql was redone
  # has_one :investigation,
  #   :finder_sql => 'SELECT data_collectors.* FROM data_collectors
  #   INNER JOIN page_elements ON data_collectors.id = page_elements.embeddable_id AND page_elements.embeddable_type = "DataCollector"
  #   INNER JOIN pages ON page_elements.page_id = pages.id
  #   WHERE pages.section_id = #{id}'

  has_many :page_elements, :order => :position, :dependent => :destroy
  has_many :inner_page_pages 
  has_many :inner_pages, :through => :inner_page_pages
  
  @@element_types = [
    Xhtml,
    OpenResponse,
    MultipleChoice,
    DataTable,
    DrawingTool,
    DataCollector,
    LabBookSnapshot,
    InnerPage,
    MwModelerPage,
    NLogoModel,
    BiologicaWorld,
    BiologicaOrganism,
    BiologicaStaticOrganism,
    BiologicaChromosome,
    BiologicaChromosomeZoom,
    BiologicaBreedOffspring,
    BiologicaPedigree,
    BiologicaMultipleOrganism,
    BiologicaMeiosisView,
    # BiologicaDna,
    Smartgraph::RangeQuestion,
  ]

  @@element_types.each do |type|
    unless defined? type.dont_make_associations
      eval "has_many :#{type.to_s.tableize.gsub('/','_')}, :through => :page_elements, :source => :embeddable, :source_type => '#{type.to_s}'"
    end
  end

  has_many :teacher_notes, :as => :authored_entity
  has_many :author_notes, :as => :authored_entity
  include Noteable # convinience methods for notes...
    
  acts_as_replicatable
  acts_as_list :scope => :section
  
  include Changeable
  # validates_presence_of :name, :on => :create, :message => "can't be blank"

  accepts_nested_attributes_for :page_elements, :allow_destroy => true 
  
  default_value_for :position, 1;
  default_value_for :description, ""

  send_update_events_to :investigation
  
  def Page::element_types
    @@element_types
  end

  def Page::paste_acceptable_types
    Page::element_types.map {|t| t.name.underscore}
  end

  self.extend SearchableModel
  @@searchable_attributes = %w{name description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
    
    def display_name
      "Page"
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
      when InnerPage
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
  #     xhtml = Xhtml.create
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
    i_pages = page_elements.collect {|e| e.embeddable_type == InnerPage.name}
    if (i_pages.size > 0) 
      return true
    end
    return false
  end
  
  def children
    # maybe what is the child we wonder?
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
  
end
