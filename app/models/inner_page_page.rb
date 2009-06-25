class InnerPagePage < ActiveRecord::Base
  belongs_to :page
  belongs_to :inner_page
  belongs_to :user
  acts_as_list :scope => :inner_page
  
  acts_as_replicatable
  include Changeable
  
  def parent
    return inner_page
  end
  
end
