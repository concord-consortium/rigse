class CreateDataCollectors < ActiveRecord::Migration
  def self.up
    create_table :data_collectors do |t|
      t.string      :name
      t.string      :description
      t.integer     :user_id
      t.column      :uuid, :string, :limit => 36
      t.integer     :y_axis_min, :default => 0
      t.integer     :y_axis_max, :default => 5
      t.integer     :x_axis_min, :default => 0
      t.integer     :x_axis_max, :default => 60
    end
  end

  def self.down
    drop_table :data_collectors
  end
end
