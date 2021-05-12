class AddOtmlContentToDataCollectors < ActiveRecord::Migration[5.1]
  def self.up
    add_column :data_collectors, :otml_root_content, :text
    add_column :data_collectors, :otml_library_content, :text
    add_column :data_collectors, :data_store_values, :text
  end

  def self.down
    remove_column :data_collectors, :otml_root_content
    remove_column :data_collectors, :otml_library_content
    remove_column :data_collectors, :data_store_values
  end
end
