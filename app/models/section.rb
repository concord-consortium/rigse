class Section < ActiveRecord::Base
  belongs_to :activity
  belongs_to :user
  has_one :investigation, :through => :activity
  
  has_many :pages, :order => :position, :dependent => :destroy

  has_many :data_collectors, :class_name => 'Embeddable::DataCollector',
     :finder_sql => 'SELECT embeddable_data_collectors.* FROM embeddable_data_collectors
     INNER JOIN page_elements ON embeddable_data_collectors.id = page_elements.embeddable_id AND page_elements.embeddable_type = "Embeddable::DataCollector"
     INNER JOIN pages ON page_elements.page_id = pages.id
     WHERE pages.section_id = #{id}'
     
  has_many :page_elements,
    :finder_sql => 'SELECT page_elements.* FROM page_elements
    INNER JOIN pages ON page_elements.page_id = pages.id 
    WHERE pages.section_id = #{id}'
  
  acts_as_list :scope => :activity_id
  accepts_nested_attributes_for :pages, :allow_destroy => true 

  acts_as_replicatable

  include Changeable
  
  has_many :teacher_notes, :as => :authored_entity
  has_many :author_notes, :as => :authored_entity
  include Noteable # convinience methods for notes...
  
  validates_presence_of :name, :on => :create, :message => "can't be blank"
  
  default_value_for :name, "name of section"
  default_value_for :description, "describe the purpose of this section here..."
  
  send_update_events_to :investigation
  
  def self.display_name
    'Section'
  end

  def parent
    return activity
  end
  
  def children
    return pages
  end

  include TreeNode
  
end



#  Recent schema definition:
# create_table "sections", :force => true do |t|
#   t.datetime "created_at"
#   t.datetime "updated_at"
#   t.string   "name"
#   t.string   "description"
#   t.integer  "user_id"
#   t.integer  "position"
#   t.integer  "activity_id"
#   t.string   "uuid",             :limit => 36
# end
