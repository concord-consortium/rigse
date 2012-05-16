class AddJnlpCdnHostnameToAdminProject < ActiveRecord::Migration
  def change
    add_column :admin_projects, :jnlp_cdn_hostname, :string
  end
end
