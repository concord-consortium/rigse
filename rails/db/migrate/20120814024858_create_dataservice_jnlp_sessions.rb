class CreateDataserviceJnlpSessions < ActiveRecord::Migration[5.1]
  def change
    create_table :dataservice_jnlp_sessions do |t|
      t.string :token
      t.integer :user_id
      t.integer :access_count, :default => 0
      t.timestamps
    end
    add_index :dataservice_jnlp_sessions, :token
  end
end
