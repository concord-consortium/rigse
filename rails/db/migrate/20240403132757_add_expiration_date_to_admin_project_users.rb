class AddExpirationDateToAdminProjectUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :admin_project_users, :expiration_date, :date, null: true
    add_index :admin_project_users, [:is_researcher, :expiration_date], name: 'index_project_users_on_researcher_and_expiration'
  end
end
