class CreateMavenJnlpMavenJnlpFamilies < ActiveRecord::Migration
  def self.up
    create_table :maven_jnlp_maven_jnlp_families do |t|
      t.integer :maven_jnlp_server_id
      t.string :uuid
      t.string :name
      t.string :snapshot_version
      t.string :url

      t.timestamps
    end
  end

  def self.down
    drop_table :maven_jnlp_maven_jnlp_families
  end
end
