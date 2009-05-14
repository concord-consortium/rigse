class CreateAuthorNotes < ActiveRecord::Migration
  def self.up
    create_table :author_notes do |t|
      t.text        :body
      t.text        :author
      t.column      :uuid, :string, :limit => 36
      
      t.integer     :authored_entity_id
      t.string      :authored_entity_type
      
      t.timestamps
    end
  end

  def self.down
    drop_table :author_notes
  end
end
