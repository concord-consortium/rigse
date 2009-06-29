class ChangeJ2seFieldnameMavenJnlpVersionedJnlp < ActiveRecord::Migration
  def self.up
    rename_column :maven_jnlp_versioned_jnlps, :j2se, :j2se_version
  end

  def self.down
    rename_column :maven_jnlp_versioned_jnlps, :j2se_version, :j2se
  end
end
