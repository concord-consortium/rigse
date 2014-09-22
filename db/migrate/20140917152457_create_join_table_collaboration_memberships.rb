class CreateJoinTableCollaborationMemberships < ActiveRecord::Migration
  def change
    create_table :collaboration_memberships do |t|
      t.integer :collaboration_id
      t.integer :student_id
      t.string :access_token
      t.timestamps
    end
  end
end
