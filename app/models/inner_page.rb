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
  
  def self.display_name
    "Innerpage"
  end

  def parent
    pages[0]
  end
  
  def children
    sub_pages
  end
  
end
