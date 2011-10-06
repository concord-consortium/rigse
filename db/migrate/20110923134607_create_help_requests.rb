class CreateHelpRequests < ActiveRecord::Migration
  def self.up
    create_table :help_requests do |t|
      t.string :name
      t.string :email
      t.string :class_name
      t.string :activity
      t.int :num_students
      t.string :computer_type
      t.string :problem_type
      t.string :all_computers
      t.string :pre_loaded
      t.text :more_info
      t.text :console
      t.string :login
      t.string :os
      t.string :browser
      t.string :ip_address
      t.text :referrer

      t.timestamps
    end
  end

  def self.down
    drop_table :help_requests
  end
end
