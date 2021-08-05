class AddStaticPageToInnerPage < ActiveRecord::Migration[5.1]
  def self.up
    add_column :inner_pages, :static_page_id, :integer
  end

  def self.down
    remove_column :inner_pages, :static_page_id
  end
end
