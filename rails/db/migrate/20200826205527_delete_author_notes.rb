class DeleteAuthorNotes < ActiveRecord::Migration
  def self.up
    drop_table :author_notes
  end

  def self.down
    create_table :author_notes do |t|
      t.text        :body
      t.integer     :user_id
      t.column      :uuid, :string, :limit => 36

      t.integer     :authored_entity_id
      t.string      :authored_entity_type

      t.timestamps
    end
  end
end
