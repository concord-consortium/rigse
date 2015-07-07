class AddDomainToClient < ActiveRecord::Migration
  def change
    add_column :clients, :domain, :string
  end
end
