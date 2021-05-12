class AddAllowActivityAssignment < ActiveRecord::Migration[5.1]
  def change
    add_column :investigations,      :allow_activity_assignment, :boolean, :default => true
  end
end
