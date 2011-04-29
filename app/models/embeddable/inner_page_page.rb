class Embeddable::InnerPagePage < ActiveRecord::Base
  set_table_name "embeddable_inner_page_pages"

  belongs_to :page
  belongs_to :inner_page, :class_name => 'Embeddable::InnerPage'
  belongs_to :user
  acts_as_list :scope => :inner_page
  
  acts_as_replicatable
  include Changeable
  
  def parent
    return inner_page
  end
  
end
