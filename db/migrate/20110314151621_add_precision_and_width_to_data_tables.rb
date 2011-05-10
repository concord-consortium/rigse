class AddPrecisionAndWidthToDataTables < ActiveRecord::Migration
  def self.up
    # default for precision comes from the pt story: 
    # https://www.pivotaltracker.com/story/show/8840073
    add_column :embeddable_data_tables, :precision, :int, :default => 2
    # default for width taken directly from OTDataTable java class defs.
    add_column :embeddable_data_tables, :width, :int, :default => 1200
  end

  def self.down
    remove_column :embeddable_data_tables, :width
    remove_column :embeddable_data_tables, :precision
  end
end
