class AddContentToResourcePage < ActiveRecord::Migration
  def self.up
    add_column :resource_pages, :content, :text
    # copy description to text
    execute 'update resource_pages set content=description'
    execute 'update resource_pages set description=NULL'
  end

  def self.down
    execute 'update resource_pages set description=content'
    remove_column :resource_pages, :content
  end
end
