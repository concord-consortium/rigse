class ProbesAndMore < ActiveRecord::Migration
  def self.up
    create_table :calibrations do |t|
      t.integer :data_filter_id
      t.integer :probe_type_id
      t.boolean :default_calibration
      t.integer :physical_unit_id
      t.string  :name
      t.text    :description
      t.float   :k0
      t.float   :k1
      t.float   :k2
      t.float   :k3
      t.string  :uuid
    end

    create_table :data_filters do |t|
      t.integer :user_id
      t.string  :name
      t.text    :description
      t.string  :otrunk_object_class
      t.boolean :k0_active
      t.boolean :k1_active
      t.boolean :k2_active
      t.boolean :k3_active
      t.string  :uuid
    end

    create_table :device_configs do |t|
      t.integer  :user_id
      t.integer  :vendor_interface_id
      t.string   :config_string
      t.string   :uuid
      t.datetime :created_at
      t.datetime :updated_at
    end
     
    create_table :physical_units do |t|
      t.integer :user_id
      t.string  :name
      t.string  :quantity
      t.string  :unit_symbol
      t.string  :unit_symbol_text
      t.text    :description
      t.boolean :si
      t.boolean :base_unit
      t.string  :uuid
    end

    create_table :probe_types do |t|
      t.integer :user_id
      t.string  :name
      t.integer :ptype
      t.float   :step_size
      t.integer :display_precision
      t.integer :port
      t.string  :unit
      t.float   :min
      t.float   :max
      t.float   :period
      t.string  :uuid
    end

    create_table :vendor_interfaces do |t|
      t.integer :user_id
      t.string  :name
      t.string  :short_name
      t.text    :description
      t.string  :communication_protocol
      t.string  :image
      t.string  :uuid
      t.integer :device_id
    end
  end

  def self.down
    drop_table :pages
    drop_table :calibrations
    drop_table :data_filters
    drop_table :device_configs     
    drop_table :physical_units
    drop_table :probe_types
    drop_table :vendor_interfaces
  end
end
