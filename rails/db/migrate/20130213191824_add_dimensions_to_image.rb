class AddDimensionsToImage < ActiveRecord::Migration
  def change
    add_column :images, :width, :integer,  :default => 0
    add_column :images, :height, :integer, :default => 0
  end
end
