class CreateSections < ActiveRecord::Migration[5.1]
  def self.up
    create_table :sections do |t|
      t.integer     :user_id
      t.integer     :investigation_id
      t.column      :uuid, :string, :limit => 36

      t.string      :name
      t.text        :description
      t.integer     :position

      t.timestamps
    end
    add_index :sections, :position
  end

  def self.down
    remove_index :sections, :position
    drop_table :sections
  end
end
