class Section < ActiveRecord::Base
  belongs_to :investigation
  belongs_to :user
  has_many :pages, :order => :position, :dependent => :destroy
  acts_as_list :scope => :investigation_id
  accepts_nested_attributes_for :pages, :allow_destroy => true 
  acts_as_replicatable
  default_value_for :pages do
    page = Page.create()
    [] << page
  end
  
end


#  Recent schema definition:
# create_table "sections", :force => true do |t|
#   t.datetime "created_at"
#   t.datetime "updated_at"
#   t.string   "name"
#   t.string   "description"
#   t.integer  "user_id"
#   t.integer  "position"
#   t.integer  "investigation_id"
#   t.string   "uuid",             :limit => 36
# end
