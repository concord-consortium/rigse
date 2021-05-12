class AddSecurityQuestionSettingToAdminProjects < ActiveRecord::Migration[5.1]
  def self.up
    add_column :admin_projects, :use_student_security_questions, :boolean, :default => false
  end

  def self.down
    drop_column :admin_projects, :use_student_security_questions
  end
end
