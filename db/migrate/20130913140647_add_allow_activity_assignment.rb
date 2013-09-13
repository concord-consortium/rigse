class AddAllowActivityAssignment < ActiveRecord::Migration
  def change
    add_column :investigations,      :allow_activity_assignment, :boolean, :default => true
  end
end
