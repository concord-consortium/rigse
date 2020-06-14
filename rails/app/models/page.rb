class Page < ActiveRecord::Base
  include JnlpLaunchable
  include Clipboard

  belongs_to :user
  belongs_to :section
  has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"

  has_many :external_activities, :as => :template

  has_one :activity, :through => :section

  # Order by ID is important, see: https://www.pivotaltracker.com/story/show/79237764
  # Some older elements in DB can have always position equal to 1.
  has_many :page_elements, :order => 'position ASC, id ASC', :dependent => :destroy

  # The array of embeddables is defined in conf/initializers/embeddables.rb
  # The order of this array determines the order they show up in the Add menu
  @@element_types = ALL_EMBEDDABLES

  # @@element_types.each do |type|
  #   unless defined? type.dont_make_associations
  #     eval "has_many :#{type.to_s.tableize.gsub('/','_')}, :through => :page_elements, :source => :embeddable, :source_type => '#{type.to_s}'"
  #   end
  # end

  @@element_types.each do |klass|
    unless defined? klass.dont_make_associations
      eval %!has_many :#{klass[/::(\w+)$/, 1].underscore.pluralize}, :class_name => '#{klass}',
      :finder_sql => proc { "SELECT #{klass.constantize.table_name}.* FROM #{klass.constantize.table_name}
      INNER JOIN page_elements ON #{klass.constantize.table_name}.id = page_elements.embeddable_id AND page_elements.embeddable_type = '#{klass}'
      WHERE page_elements.page_id = \#\{id\}" }!
    end
  end

  include ResponseTypes

  has_many :teacher_notes, :dependent => :destroy, :as => :authored_entity
  has_many :author_notes, :dependent => :destroy, :as => :authored_entity
  include Noteable # convenience methods for notes...

  include Publishable
  include Archiveable

  acts_as_replicatable
  acts_as_list :scope => :section

  scope :like, lambda { |name|
    name = "%#{name}%"
    where("pages.name LIKE ? OR pages.description LIKE ?", name, name)
  }

  include Changeable
  # validates_presence_of :name, :on => :create, :message => "can't be blank"

  accepts_nested_attributes_for :page_elements, :allow_destroy => true

  default_value_for :description, ""

  send_update_events_to :investigation

  self.extend SearchableModel
  @@searchable_attributes = %w{name description}

  include Cloneable
  @@cloneable_associations = [:page_elements]

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

    def cloneable_associations
      @@cloneable_associations
    end

    # returns an array of class names transmogrified into the form
    # we use for dom-ids
    def paste_acceptable_types
      element_types.map {|t| t.name.underscore.clipboardify}
    end

    # Returns the embeddables list as constants (classes) rather than strings
    def element_types
      @@element_types.map { |e| e.constantize }
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
    return parent
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

  def add_embeddable(embeddable, position = nil)
    page_elements << PageElement.create(:user => user, :embeddable => embeddable, :position => position)
  end

  def add_element(element)
    element.pages << self
    element.save
  end


  # return element.id for the component passed in
  # so for example, pass in an MultipleChoice item in, and get back a page_elements object.
  # assumes that this page contains component.  Because this can cause confusion,
  # if we pass in a page_element we directly return that.
  def element_for(component)
    if component.instance_of? PageElement
      return component
    end
    return component.page_elements.detect {|pe| pe.embeddable.id == component.id }
  end

  def parent
    return section
  end

  include TreeNode


  def investigation
    activity = find_activity
    investigation = activity ? activity.investigation : nil
  end

  def has_inner_page?
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

  def print_listing
    []
  end
end
