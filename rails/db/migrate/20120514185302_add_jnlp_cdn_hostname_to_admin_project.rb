class AddJnlpCdnHostnameToAdminProject < ActiveRecord::Migration[5.1]
  def self.up
    add_column :admin_projects, :jnlp_cdn_hostname, :string
  end

  def self.down
    remove_column :admin_projects, :jnlp_cdn_hostname
  end
end
