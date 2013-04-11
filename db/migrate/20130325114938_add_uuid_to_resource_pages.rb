class AddUuidToResourcePages < ActiveRecord::Migration
  def change
    add_column :resource_pages, :uuid, :string
  end
end
