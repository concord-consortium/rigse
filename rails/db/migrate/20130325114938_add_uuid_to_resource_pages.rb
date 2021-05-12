class AddUuidToResourcePages < ActiveRecord::Migration[5.1]
  def change
    add_column :resource_pages, :uuid, :string
  end
end
