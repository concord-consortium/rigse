class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.integer     :scope_id
      t.string      :scope_type
      t.string      :name
      t.string      :value
      t.timestamps
    end
    add_index :settings, [:scope_id  , :scope_type, :name]
    add_index :settings, [:scope_type, :scope_id,   :name]
    add_index :settings, :name
    add_index :settings, :value
  end

  def self.down
    remove_index :settings, :scope_id
    remove_index :settings, :scope_type    
    remove_index :settings, :name
    remove_index :settings, :value
    drop_table :settings
  end
end
