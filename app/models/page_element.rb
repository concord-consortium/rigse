class PageElement < ActiveRecord::Base
  belongs_to :user
  belongs_to :page
  acts_as_list :scope => :page_id
  belongs_to :embeddable, :polymorphic => true

  # this could work if the finder sql was redone
  # has_one :investigation,
  #   :finder_sql => 'SELECT embeddable_data_collectors.* FROM embeddable_data_collectors
  #   INNER JOIN page_elements ON embeddable_data_collectors.id = page_elements.embeddable_id AND page_elements.embeddable_type = "Embeddable::DataCollector"
  #   INNER JOIN pages ON page_elements.page_id = pages.id
  #   WHERE pages.section_id = #{id}'
  
  # TODO the old named_scope (now page_by_investigation) didn't include elements in inner pages.
  # this method combines elements in pages, with elements in innerpages
  # it may or may not be possible to integrate them into one named_scope
  def self.by_investigation(investigation)
    page_page_elements = PageElement.page_by_investigation(investigation)
    inner_page_page_elements = PageElement.inner_page_by_investigation(investigation)
    return (page_page_elements + inner_page_page_elements).compact.uniq
  end
  
  named_scope :page_by_investigation, lambda {|investigation|
    { :select => 'page_elements.*, pages.position as page_position, sections.id as section_id, sections.position as section_position, activities.id as activity_id, activities.position as activity_position',
      :joins => 'INNER JOIN pages ON page_elements.page_id = pages.id 
      INNER JOIN sections ON pages.section_id = sections.id
      INNER JOIN activities ON sections.activity_id = activities.id',
      :conditions => {'activities.investigation_id' => investigation.id },
      :order => 'activity_position asc, section_position asc, page_position asc, page_elements.position asc'
    }
  }
  
  def self.inner_page_by_investigation(investigation)
    Embeddable::InnerPage.all.select{|p| p.investigation.id == investigation.id}.collect{|ip| ip.children.collect{|p| p.children}}.flatten.uniq
  end
  
  # to be used with the by_investigation scope only
  named_scope :student_only, lambda {
    { :conditions => {'pages.teacher_only' => false, 'sections.teacher_only' => false, 'activities.teacher_only' => false }
    }
  }
  
  named_scope :by_type, lambda {|types|
    { :conditions => {'embeddable_type' => types},
      :order => 'position asc'
    }
  }

  include Changeable

  # only destroy the embeddable if it isn't referenced by any other page elements
  def before_destroy
    if self.embeddable ## FIXME This shouldn't happen -- if the embeddable never gets created, this page_element shouldn't exist either!
      other_related_page_elements = self.embeddable.page_elements.uniq - [self]
      self.embeddable.destroy if other_related_page_elements.empty?
    end
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
    @copy = self.clone
    @em = self.embeddable
    
    # let embeddables define their own means to save
    if @em.respond_to? :duplicate
      @copy.embeddable = @em.duplicate
    else
      @copy.embeddable = @em.clone
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
      elsif Investigation.reportable_types.include?(embeddable.class)
        @reportable_elements << {:embeddable => embeddable, :page_element => self}
      end
    end
    return @reportable_elements
  end
end
