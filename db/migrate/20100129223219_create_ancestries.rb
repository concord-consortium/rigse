class CreateAncestries < ActiveRecord::Migration
  def self.up
    create_table :ancestries do |t|
      t.integer     :ancestor_id
      t.string      :ancestor_type
      t.integer     :descendant_id
      t.string      :descendant_type
      t.timestamps
    end
    add_index :ancestries, :ancestor_id
    add_index :ancestries, :ancestor_type
    add_index :ancestries, :descendant_id
  end

  def self.down
    remove_index :ancestries, :ancestor_id
    remove_index :ancestries, :ancestor_type
    remove_index :ancestries, :descendant_id
    drop_table :ancestries
  end
end
