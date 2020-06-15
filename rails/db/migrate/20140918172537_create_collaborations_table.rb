class CreateCollaborationsTable < ActiveRecord::Migration
  def change
    create_table :portal_collaborations do |t|
      t.integer :owner_id
      t.timestamps
    end
  end
end
