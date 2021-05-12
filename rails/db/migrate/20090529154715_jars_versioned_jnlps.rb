class JarsVersionedJnlps < ActiveRecord::Migration[5.1]
  def self.up
    create_table :jars_versioned_jnlps, :id => false do |t|
      t.integer :jar_id
      t.integer :versioned_jnlp_id
    end
  end

  def self.down
    drop_table :jars_versioned_jnlps
  end
end
