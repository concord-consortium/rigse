class AddTeacherInfoToReportLearner < ActiveRecord::Migration
  module Report
  end
  module Portal
  end

  class Report::Learner < ActiveRecord::Base
    self.table_name = :report_learners
    belongs_to :clazz, :class_name => "AddTeacherInfoToReportLearner::Portal::Clazz", :foreign_key => "class_id"

    def update_teacher_info_fields
      self.teachers_district = clazz.teachers.map{ |t| t.schools.map{ |s| s.district.name}.join(", ")}.join(", ")
      self.teachers_state = clazz.teachers.map{ |t| t.schools.map{ |s| s.district.state}.join(", ")}.join(", ")
      self.teachers_email = clazz.teachers.map{ |t| t.user.email}.join(", ")
      save!
    end
  end

  class Portal::Clazz < ActiveRecord::Base
    self.table_name = :portal_clazzes
    has_many :teacher_clazzes, :class_name => "AddTeacherInfoToReportLearner::Portal::TeacherClazz", :foreign_key => "clazz_id"
    has_many :teachers, :through => :teacher_clazzes, :class_name => "Portal::Teacher"
  end

  class Portal::TeacherClazz < ActiveRecord::Base
    self.table_name = :portal_teacher_clazzes
    belongs_to :clazz, :class_name => "AddTeacherInfoToReportLearner::Portal::Clazz", :foreign_key => "clazz_id"
    belongs_to :teacher, :class_name => "Portal::Teacher", :foreign_key => "teacher_id"
  end

  # need to use normal class name here inorder for polymorhpic type to work correctly
  class ::Portal::Teacher < ActiveRecord::Base
    self.table_name = :portal_teachers
    has_many :school_memberships, :as => :member, :class_name => "AddTeacherInfoToReportLearner::Portal::SchoolMembership"
    has_many :schools, :through => :school_memberships, :class_name => "AddTeacherInfoToReportLearner::Portal::School", :uniq => true
    belongs_to :user, :class_name => "AddTeacherInfoToReportLearner::User", :foreign_key => "user_id"
  end

  class User < ActiveRecord::Base
  end

  class Portal::SchoolMembership < ActiveRecord::Base
    self.table_name = :portal_school_memberships
    belongs_to :school, :class_name => "AddTeacherInfoToReportLearner::Portal::School", :foreign_key => "school_id"
    belongs_to :member, :polymorphic => true
  end

  class Portal::School < ActiveRecord::Base
    self.table_name = :portal_schools
    belongs_to :district, :class_name => "AddTeacherInfoToReportLearner::Portal::District", :foreign_key => "district_id"
  end

  class Portal::District < ActiveRecord::Base
    self.table_name = :portal_districts
  end

  def up
    add_column :report_learners, :teachers_district, :string
    add_column :report_learners, :teachers_state,    :string
    add_column :report_learners, :teachers_email,    :string

    AddTeacherInfoToReportLearner::Report::Learner.reset_column_information

    AddTeacherInfoToReportLearner::Report::Learner.includes(clazz: {teachers: [{ schools: :district }, :user] }).find_each(batch_size: 100) do |rl|
      rl.update_teacher_info_fields
      rl.save!
    end
  end

  def down
    remove_column :report_learners, :teachers_district
    remove_column :report_learners, :teachers_state
    remove_column :report_learners, :teachers_email
  end
end
