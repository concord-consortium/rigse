class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.timestamps
      t.string      :name
      t.string      :description
      t.integer     :user_id
      t.integer     :position
      t.integer     :section_id
      t.column      :uuid, :string, :limit => 36
    end
    add_index :pages, :position
  end

  def self.down
    remove_index :pages, :position
    drop_table :pages
  end
end
