class AddTeacherIdToAccessGrants < ActiveRecord::Migration[5.1]
  def change
    add_column :access_grants, :teacher_id, :integer
    add_index :access_grants, :teacher_id
  end
end
