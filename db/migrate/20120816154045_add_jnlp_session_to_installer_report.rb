class AddJnlpSessionToInstallerReport < ActiveRecord::Migration
  def change
    add_column :installer_reports, :jnlp_session_id, :integer
  end
end
