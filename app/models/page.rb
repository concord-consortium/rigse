class Page < ActiveRecord::Base
  belongs_to :user
  belongs_to :section, :class_name => "Section", :foreign_key => "section_id"
  has_many :page_elements, :order => :position

  acts_as_list
  accepts_nested_attributes_for :page_elements, :allow_destroy => true 
  
  default_value_for :position, 1;
  default_value_for :description, "first page"
  default_value_for :name, "Page 1"
  default_value_for :description, "This is the first page of this section"
  
  # create_table "pages", :force => true do |t|
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   t.string   "name"
  #   t.string   "description"
  #   t.integer  "user_id"
  #   t.integer  "position"
  #   t.integer  "section_id"
  #   t.string   "uuid",        :limit => 36
  # end  
end
