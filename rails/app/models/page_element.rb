class PageElement < ActiveRecord::Base
  belongs_to :user
  belongs_to :page
  acts_as_list :scope => :page_id
  belongs_to :embeddable, :polymorphic => true

  # TODO the old scope (now page_by_investigation) didn't include elements in inner pages.
  # this method combines elements in pages, with elements in innerpages
  # it may or may not be possible to integrate them into one scope
  def self.by_investigation(investigation)
    return PageElement.page_by_investigation(investigation)
  end
  
  scope :page_by_investigation, lambda {|investigation|
    select('page_elements.*,
      pages.position as page_position,
      sections.id as section_id,
      sections.position as section_position,
      activities.id as activity_id,
      activities.position as activity_position')
      .joins('INNER JOIN pages ON page_elements.page_id = pages.id
      INNER JOIN sections ON pages.section_id = sections.id
      INNER JOIN activities ON sections.activity_id = activities.id')
     .where('activities.investigation_id' => investigation.id)
     .order('activity_position asc, section_position asc, page_position asc, page_elements.position asc')
  }

  # to be used with the by_investigation scope only
  scope :student_only, -> {
    where('pages.teacher_only' => false)
        .where('sections.teacher_only' => false)
        .where('activities.teacher_only' => false)
  }
  
  scope :by_type, lambda { |types|
    where('embeddable_type' => types).order('position asc')
  }

  include Changeable

  include Cloneable
  @@cloneable_associations = [:embeddable]

  class <<self
    def cloneable_associations
      @@cloneable_associations
    end
  end

  before_destroy :check_for_other_references

  # only destroy the embeddable if it isn't referenced by any other page elements
  def check_for_other_references
    other_related_page_elements = self.embeddable.page_elements.uniq - [self]
    self.embeddable.destroy if other_related_page_elements.empty?
  end

  def dom_id
    "page_element_#{self.id}"
  end
  
  def teacher_only?
    false
  end
  
  def parent
    return page
  end
  
  def duplicate
    @copy = self.deep_clone :no_duplicates => true, :never_clone => [:uuid, :updated_at,:created_at]
    @em = self.embeddable
    
    # let embeddables define their own means to save
    if @em.respond_to? :duplicate
      @copy.embeddable = @em.duplicate
    else
      @copy.embeddable = @em.deep_clone :no_duplicates => true, :never_clone => [:uuid, :updated_at,:created_at]
    end
    
    if @copy.embeddable
      @copy.embeddable.save
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
      if embeddable.respond_to?(:reportable_elements)
        @reportable_elements = embeddable.reportable_elements
      elsif ResponseTypes.reportable_types.include?(embeddable.class)
        @reportable_elements << {:embeddable => embeddable, :page_element => self}
      end
    end
    return @reportable_elements
  end

  def question_number
    page.activity.question_number(embeddable)
  end
end
