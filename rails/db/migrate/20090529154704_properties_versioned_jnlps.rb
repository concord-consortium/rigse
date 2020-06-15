class PropertiesVersionedJnlps < ActiveRecord::Migration
  def self.up
    create_table :properties_versioned_jnlps, :id => false do |t|
      t.integer :property_id
      t.integer :versioned_jnlp_id
    end
  end

  def self.down
    drop_table :properties_versioned_jnlps
  end
end
