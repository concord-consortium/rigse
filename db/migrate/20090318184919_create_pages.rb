class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.integer     :user_id
      t.integer     :section_id
      t.column      :uuid, :string, :limit => 36

      t.string      :name
      t.text        :description
      t.integer     :position

      t.timestamps
    end
    add_index :pages, :position
  end

  def self.down
    remove_index :pages, :position
    drop_table :pages
  end
end
