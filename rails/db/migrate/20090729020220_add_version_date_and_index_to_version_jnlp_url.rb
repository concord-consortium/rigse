class AddVersionDateAndIndexToVersionJnlpUrl < ActiveRecord::Migration
  def self.up
    add_column :maven_jnlp_versioned_jnlp_urls, :date_str, :string, :limit => 15
    add_index :maven_jnlp_versioned_jnlp_urls, :date_str
    add_index :maven_jnlp_versioned_jnlp_urls, :version_str
    add_index :maven_jnlp_versioned_jnlp_urls, :maven_jnlp_family_id
    remove_column :maven_jnlp_versioned_jnlp_urls, :created_at
    remove_column :maven_jnlp_versioned_jnlp_urls, :updated_at
    
  end

  def self.down
    add_column :maven_jnlp_versioned_jnlp_urls, :created_at, :datetime
    add_column :maven_jnlp_versioned_jnlp_urls, :updated_at, :datetime
    remove_index :maven_jnlp_versioned_jnlp_urls, :maven_jnlp_family_id
    remove_index :maven_jnlp_versioned_jnlp_urls, :version_str
    remove_index :maven_jnlp_versioned_jnlp_urls, :date_str
    remove_column :maven_jnlp_versioned_jnlp_urls, :date_str
  end
end
