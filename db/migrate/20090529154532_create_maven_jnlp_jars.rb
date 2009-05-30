class CreateMavenJnlpJars < ActiveRecord::Migration
  def self.up
    create_table :maven_jnlp_jars do |t|
      t.string :uuid
      t.string :name
      t.boolean :main
      t.string :os
      t.string :href
      t.integer :size
      t.integer :size_pack_gz
      t.boolean :signature_verified
      t.string :version_str

      t.timestamps
    end
  end

  def self.down
    drop_table :maven_jnlp_jars
  end
end
