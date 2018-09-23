# self.table_name = :portal_teachers
# 
# belongs_to :user, :class_name => "User", :foreign_key => "user_id"
# 
# has_many :offerings, :through => :clazzes
# 
# has_many :grade_levels, :as => :has_grade_levels, :class_name => "Portal::GradeLevel"
# has_many :grades, :through => :grade_levels, :class_name => "Portal::Grade"
# 
# has_many :subjects, :class_name => "Portal::Subject", :foreign_key => "teacher_id"
# has_many :clazzes, :class_name => "Portal::Clazz", :foreign_key => "teacher_id", :source => :clazz


FactoryBot.define do
  factory :teacher, :class => Portal::Teacher do |f|
    f.association :user, :factory => :confirmed_user
    f.clazzes {|clazzes| [clazzes.association(:portal_clazz)]}
  end
end

FactoryBot.define do
  factory :portal_teacher, :parent => :teacher do |f|
    f.schools {|schools| [schools.association(:portal_school)]}
  end
end

# a teacher with one class in a real school
FactoryBot.define do
  factory :nces_portal_teacher, :parent => :portal_teacher do |teacher|
    teacher.clazzes {[FactoryBot.create(:nces_portal_clazz)]}
  end
end

