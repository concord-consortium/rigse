class CreateSections < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.timestamps
      t.string      :name
      t.string      :description
      t.integer     :user_id
      t.integer     :position
      t.integer     :investigation_id
      t.column      :uuid, :string, :limit => 36
    end
    add_index :sections, :position
  end

  def self.down
    remove_index :sections, :position
    drop_table :sections
  end
end
