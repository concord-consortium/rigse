class NativeLibrariesVersionedJnlps < ActiveRecord::Migration[5.1]
  def self.up
    create_table :native_libraries_versioned_jnlps, :id => false do |t|
      t.integer :native_library_id
      t.integer :versioned_jnlp_id
    end
  end

  def self.down
    drop_table :native_libraries_versioned_jnlps
  end
end