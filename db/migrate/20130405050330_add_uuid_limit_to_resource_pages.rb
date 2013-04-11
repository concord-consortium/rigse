class AddUuidLimitToResourcePages < ActiveRecord::Migration
  def change
    change_column :resource_pages, :uuid, :string, :limit => 36
  end
end
