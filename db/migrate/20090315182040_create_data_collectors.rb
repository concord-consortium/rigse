class CreateDataCollectors < ActiveRecord::Migration
  def self.up
    create_table :data_collectors do |t|
      t.string      :name
      t.text        :description
      t.integer     :probe_type_id
      t.integer     :user_id
      t.string      :uuid,               :limit => 36
      t.string      :title

      t.float       :y_axis_min,         :default => 0
      t.float       :y_axis_max,         :default => 5
      t.float       :x_axis_min
      t.float       :x_axis_max

      t.string      :x_axis_label,       :default => "Time"
      t.string      :x_axis_units,       :default => "s"
      t.string      :y_axis_label
      t.string      :y_axis_units

      t.boolean     :multiple_graphable_enabled, :default => false

      t.boolean     :draw_marks,         :default => false
      t.boolean     :connect_points,     :default => true
      t.boolean     :autoscale_enabled,  :default => false
      t.boolean     :ruler_enabled,      :default => false
      t.boolean     :show_tare,          :default => false
      t.boolean     :single_value,       :default => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :data_collectors
  end
end
