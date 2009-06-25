class CreateInnerPagePages < ActiveRecord::Migration
  def self.up
    create_table :inner_page_pages do |t|
      t.integer     :inner_page_id
      t.integer     :page_id
      t.integer     :user_id
      t.string      :uuid,        :limit => 36  
      t.integer     :position
      t.timestamps
    end
    add_index :inner_page_pages, :position
    add_index :inner_page_pages, :inner_page_id
    add_index :inner_page_pages, :page_id
  end

  def self.down
    drop_table :inner_page_pages
  end
 
end
