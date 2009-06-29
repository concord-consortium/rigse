class InnerPage < ActiveRecord::Base
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :inner_page_pages, :order => :position, :dependent => :destroy
  has_many :sub_pages, :class_name => "Page", :through => :inner_page_pages, :source => "page"
  
  acts_as_replicatable

  include Changeable
  include TreeNode

  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  default_value_for :name, "InnerPage element"
  default_value_for :description, "description ..."

  def self.dont_make_associations
    true
  end
  
  def add_page(new_page)
    self.sub_pages << new_page
    new_page.save
    self.save
    self.reload
    new_page.reload
  end
  alias << add_page
  
  def self.display_name
    "Inner Page"
  end

  def parent
    pages[0]
  end
  
  
  def section
    if parent
      return parent.activity
    end
    return nil
  end

  def activity
    if section
      return section.activity
    end
    return nil
  end
  
  def investigation
    if activity
      return activity.investigation
    end
  end
  
  
  def children
    sub_pages
  end
  
  def delete_page(page)
    index = sub_pages.index(page)
    if (index > -1)
      inner_page_pages[index].remove_from_list
      inner_page_pages[index].destroy
      # inner_page_pages.compact
      # inner_page_pages.each_with_index do |ipp,index|
      #   ipp.position=index
      #   ipp.save
      # end
      # page.destroy? or is that being to harsh?
    else
      throw "cant deal" 
    end
    self.reload
  end
  
  def menu_name
    case sub_pages.size
    when  0
      return "inner page with no pages"
    when 1
      return "inner page"
    else
      return "inner page with #{sub_pages.size} pages"
    end
  end
  
  
end
