class Ccportal::Course < Ccportal::Ccportal

  self.table_name = :portal_classes
  set_primary_key :class_id

  has_one :class_word, :foreign_key => :class_id, :class_name => "Ccportal::ClassWord"
  belongs_to :school, :foreign_key => :class_school, :class_name => "Ccportal::School"
  belongs_to :teacher, :foreign_key => :class_teacher, :class_name => 'Ccportal::Teacher'

  has_many :class_activities, :foreign_key => :class_id, :class_name => 'Ccportal::ClassActivity'

  has_many :activities, :through => :class_activities, :class_name => 'Ccportal::Activity'
  has_many :class_diy_activities, :foreign_key => :class_id, :class_name => 'Ccportal::ClassDiyActivity'

  has_many :class_students, :foreign_key => :class_id, :class_name => 'Ccportal::ClassStudent'
  has_many :students, :through => :class_students, :foreign_key => :member_id, :class_name => 'Ccportal::Student'

end
