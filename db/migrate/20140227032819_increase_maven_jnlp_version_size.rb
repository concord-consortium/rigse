class IncreaseMavenJnlpVersionSize < ActiveRecord::Migration
  def up
    change_column :maven_jnlp_versioned_jnlp_urls, :date_str, :string, :limit => nil
  end

  def down
    change_column :maven_jnlp_versioned_jnlp_urls, :date_str, :string, :limit => 15
  end
end
