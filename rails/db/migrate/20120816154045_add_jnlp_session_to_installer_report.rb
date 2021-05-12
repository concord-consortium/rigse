class AddJnlpSessionToInstallerReport < ActiveRecord::Migration[5.1]
  def change
    add_column :installer_reports, :jnlp_session_id, :integer
  end
end
