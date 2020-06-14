class AddDdFontSizeToEmbeddableDatacollectors < ActiveRecord::Migration
  def self.up
    add_column :embeddable_data_collectors, :dd_font_size, :integer
  end

  def self.down
    remove_column :embeddable_data_collectors, :dd_font_size
  end
end
