class CreateMavenJnlpVersionedJnlpUrls < ActiveRecord::Migration
  def self.up
    create_table :maven_jnlp_versioned_jnlp_urls do |t|
      t.string :uuid
      t.integer :maven_jnlp_family_id
      t.string :path
      t.string :url
      t.string :version_str

      t.timestamps
    end
  end

  def self.down
    drop_table :maven_jnlp_versioned_jnlp_urls
  end
end
