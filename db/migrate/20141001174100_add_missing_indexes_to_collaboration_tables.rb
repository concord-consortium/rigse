class AddMissingIndexesToCollaborationTables < ActiveRecord::Migration
  def change
    add_index :portal_collaborations, :owner_id
    add_index :portal_collaborations, :offering_id

    add_index :portal_collaboration_memberships, [:collaboration_id, :student_id]

    add_index :dataservice_bundle_contents, :collaboration_id
  end
end
