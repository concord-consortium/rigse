class AddAuthClientProps < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :client_type, :string, default: "confidential"
    add_column :clients, :redirect_uris, :text
  end
end
