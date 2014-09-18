class UpdateCollaborationMemberships < ActiveRecord::Migration
  def up
    # It's not necessary, can be obtained from related user object instead.
    remove_column :collaboration_memberships, :access_token
    # So it fits convention used for other tables.
    rename_table :collaboration_memberships, :portal_collaboration_memberships
  end

  def down
    rename_table :portal_collaboration_memberships, :collaboration_memberships
    add_column :collaboration_memberships, :access_token, :string
  end
end
