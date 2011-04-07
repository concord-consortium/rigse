class Embeddable::InnerPage < ActiveRecord::Base
  set_table_name "embeddable_inner_pages"

  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  belongs_to  :static_page, :class_name => "Page"
  has_many :inner_page_pages, :class_name => 'Embeddable::InnerPagePage', :order => :position, :dependent => :destroy
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

  default_value_for :name, "Embeddable::InnerPage element"
  default_value_for :description, "description ..."
  default_value_for :static_page do 
    Page.create(:name => 'static content', :description => "Static content for inner page") 
  end
  
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
      return parent.section
    end
    nil
  end

  def activity
    if section
      return section.activity
    end
    nil
  end
  
  def investigation
    if activity
      return activity.investigation
    end
    nil
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
      throw "Unknwown inner_page #{page.id} #{page.name}" 
    end
    self.reload
  end
  
  def menu_name
    title =  "inner page area"
    case sub_pages.size
    when  0
      return title << " with no pages"
    when 1
      return title
    else
      return title << " with #{sub_pages.size} pages"
    end
  end
  
  
  #
  # Duplicate: try and create a deep clone of this innerpage with all of its sub_pages
  #
  def duplicate
    @copy = self.deep_clone
    @copy.static_page = self.static_page.duplicate
    self.sub_pages.each do |page| 
      copy_of_page = page.duplicate
      @copy.sub_pages  << copy_of_page
      copy_of_page.save
    end
    @copy.save
    @copy
  end
  
  #
  # used to choose a different partial for printing.
  # see application_helper.rb#render_show_partial_for
  #
  def print_partial_name
    return "print"
  end
  
  # TODO: we have to make this container nuetral,
  # using parent / tree structure (children)
  def reportable_elements
    return @reportable_elements if @reportable_elements
    @reportable_elements = sub_pages.collect{|s| s.reportable_elements }.flatten
    return @reportable_elements
  end
end
