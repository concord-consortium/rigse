class CreatePageElements < ActiveRecord::Migration
  def self.up
    create_table :page_elements do |t|
      t.timestamps
      t.integer     :page_id
      t.integer     :position
      t.integer     :embeddable_id
      t.string      :embeddable_type
    end
    add_index :page_elements, :position
    add_index :page_elements, :page_id
    add_index :page_elements, :embeddable_id
  end

  def self.down
    remove_index :page_elements, :embeddable_id
    remove_index :page_elements, :page_id
    remove_index :page_elements, :position
    drop_table :page_elements
  end
end
