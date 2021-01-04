class CreateMavenJnlpMavenJnlpServers < ActiveRecord::Migration
  def self.up
    create_table :maven_jnlp_maven_jnlp_servers do |t|
      t.string :uuid
      t.string :host
      t.string :path
      t.string :name
      t.string :local_cache_dir

      t.timestamps
    end
  end

  def self.down
    drop_table :maven_jnlp_maven_jnlp_servers
  end
end
