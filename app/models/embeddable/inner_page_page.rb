class Embeddable::InnerPagePage < ActiveRecord::Base
  set_table_name "embeddable_inner_page_pages"

  belongs_to :page
  belongs_to :inner_page, :class_name => 'Embeddable::InnerPage'
  belongs_to :user
  acts_as_list :scope => :inner_page
  
  acts_as_replicatable
  include Changeable

  include Cloneable
  @@cloneable_associations = [:page]

  class <<self
    def cloneable_associations
      @@cloneable_associations
    end
  end

  def parent
    return inner_page
  end
  
end
