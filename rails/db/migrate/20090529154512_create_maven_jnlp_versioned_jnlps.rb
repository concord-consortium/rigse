class CreateMavenJnlpVersionedJnlps < ActiveRecord::Migration
  def self.up
    create_table :maven_jnlp_versioned_jnlps do |t|
      t.integer :versioned_jnlp_url_id
      t.integer :jnlp_icon_id
      t.string :uuid
      t.string :name
      t.string :main_class
      t.string :argument
      t.boolean :offline_allowed
      t.boolean :local_resource_signatures_verified
      t.boolean :include_pack_gzip
      t.string :spec
      t.string :codebase
      t.string :href
      t.string :j2se
      t.integer :max_heap_size
      t.integer :initial_heap_size
      t.string :title
      t.string :vendor
      t.string :homepage
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :maven_jnlp_versioned_jnlps
  end
end
