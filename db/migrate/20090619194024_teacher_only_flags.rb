class TeacherOnlyFlags < ActiveRecord::Migration
  def self.up
    [:investigations,:activities,:sections,:pages].each do |table_name|
      add_column table_name, :teacher_only, :boolean, :default => 0
    end
  end

  def self.down
    [:investigations,:activities,:sections,:pages].each do |table_name|
      remove_column table_name, :teacher_only
    end
  end
end
