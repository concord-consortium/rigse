class CreateDataCollectors < ActiveRecord::Migration
  def self.up
    create_table :data_collectors do |t|
      t.string      :name
      t.string      :contents
      t.timestamps
    end
  end

  def self.down
    drop_table :data_collectors
  end
end
