class RemoveJnlpAndOTruck < ActiveRecord::Migration[6.1]
  def up
    remove_column :admin_settings, :jnlp_cdn_hostname
    remove_column :admin_settings, :jnlp_url

    drop_table :dataservice_jnlp_sessions
    drop_table :otrunk_example_otrunk_imports
    drop_table :otrunk_example_otrunk_view_entries
  end

  def down
    # no going back!
    raise ActiveRecord::IrreversibleMigration
  end
end
