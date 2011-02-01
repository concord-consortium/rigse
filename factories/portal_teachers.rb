# set_table_name :portal_teachers
# 
# belongs_to :user, :class_name => "User", :foreign_key => "user_id"
# belongs_to :domain
# 
# has_many :offerings, :as => :runnable, :class_name => "Portal::Offering"
# 
# has_many :grade_levels, :as => :has_grade_levels, :class_name => "Portal::GradeLevel"
# has_many :grades, :through => :grade_levels, :class_name => "Portal::Grade"
# 
# has_many :subjects, :class_name => "Portal::Subject", :foreign_key => "teacher_id"
# has_many :clazzes, :class_name => "Portal::Clazz", :foreign_key => "teacher_id", :source => :clazz


Factory.define :portal_teacher, :class => Portal::Teacher do |f|
  f.association   :user, :factory => :user
  f.clazzes []
end

# a teacher with one class in a real school
Factory.define :nces_portal_teacher, :parent => :portal_teacher do |teacher|
  teacher.clazzes {[Factory(:nces_portal_clazz)]}
end

Factory.define :teacher, :class => Portal::Teacher do |f|
  f.association :user, :factory => :user
  f.clazzes { |clazzes| [ clazzes.association(:portal_clazz) ] }
end