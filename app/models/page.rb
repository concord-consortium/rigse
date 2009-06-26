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
  
  @@element_types =     [DataCollector,DrawingTool,OpenResponse,Xhtml,MultipleChoice,DataTable,MwModelerPage,NLogoModel,
        BiologicaWorld,BiologicaOrganism,BiologicaStaticOrganism,
        BiologicaChromosome,
        BiologicaChromosomeZoom,
        BiologicaBreedOffspring,
        BiologicaPedigree,
        BiologicaMultipleOrganism,
        BiologicaMeiosisView,
        InnerPage
        # BiologicaDna,
      ].sort() { |a,b| a.display_name <=> b.display_name }

  @@element_types.each do |type|
    unless defined? type.dont_make_associations
      eval "has_many :#{type.to_s.tableize}, :through => :page_elements, :source => :embeddable, :source_type => '#{type.to_s}'"
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
  default_value_for :description, "describe the purpose of this page here..."

  def Page::element_types
    @@element_types
  end

  def Page::paste_acceptable_types
    Page::element_types.map {|t| t.name.underscore}
  end

  def self.display_name
    'Page'
  end
  
  def page_number
    if (self.parent)
      return self.parent.children.index(self)+1
    end
    return 0
  end
  
  def find_section
    case parent
      when Section 
        return parent
      when InnerPage
        # kind of hackish:
        if(parent.pages[0])
          return parent.pages[0].section
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
    return (section || inner_pages[0] || nil)
  end
  
  def teacher_note
    if teacher_notes[0]
      return teacher_notes[0]
    end
    teacher_notes << TeacherNote.create
    return teacher_notes[0]
  end
  
  include TreeNode
      
  def deep_set_user user
    self.user = user
    self.page_elements.each do |e|
      if e.embeddable
        e.embeddable.user = user
        e.embeddable.save
      end
    end
    self.save
  end

  ## in_place_edit_for calls update_attribute.
  def update_attribute(name, value)
    update_investigation_timestamp if super(name, value)
  end

  ## Update timestamp of investigation that the page belongs to
  def update_investigation_timestamp
    section = self.section
    section.update_investigation_timestamp if section
  end
  
end
