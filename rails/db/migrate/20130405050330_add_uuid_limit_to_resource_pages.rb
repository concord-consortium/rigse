class AddUuidLimitToResourcePages < ActiveRecord::Migration[5.1]
  def change
    change_column :resource_pages, :uuid, :string, :limit => 36
  end
end
