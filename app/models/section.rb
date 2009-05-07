class Section < ActiveRecord::Base
  belongs_to :investigation
  belongs_to :user
  has_many :pages, :order => :position, :dependent => :destroy
  has_many :teacher_notes, :as => :authored_entity
    
  acts_as_list :scope => :investigation_id
  accepts_nested_attributes_for :pages, :allow_destroy => true 

  acts_as_replicatable

  include Changeable

  validates_presence_of :name, :on => :create, :message => "can't be blank"
  
  default_value_for :name, "name of section"
  default_value_for :description, "describe the purpose of this section here..."

  def self.display_name
    'Section'
  end

  # default_value_for :pages do
  #   [Page.create()]
  # end
  
  def teacher_note
    if teacher_notes[0]
      return teacher_notes[0]
    end
    teacher_notes << TeacherNote.create
    return teacher_notes[0]
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
