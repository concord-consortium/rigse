class Page < ActiveRecord::Base
  belongs_to :user
  belongs_to :section, :class_name => "Section", :foreign_key => "section_id"
  has_many :page_elements, :order => :position
  acts_as_list
end
