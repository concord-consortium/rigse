class AddSecurityQuestionSettingToAdminProjects < ActiveRecord::Migration
  def self.up
    add_column :admin_projects, :use_student_security_questions, :boolean, :default => false
  end

  def self.down
    drop_column :admin_projects, :use_student_security_questions
  end
end
