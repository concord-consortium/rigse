class AddDomainMatchersToClient < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :domain_matchers, :string
  end
end
