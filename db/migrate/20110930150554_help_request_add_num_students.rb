class HelpRequestAddNumStudents < ActiveRecord::Migration
  def self.up
    add_column :help_requests, :num_students, :string
  end
  def self.down
    remove_column :help_requests, :num_students
  end
end