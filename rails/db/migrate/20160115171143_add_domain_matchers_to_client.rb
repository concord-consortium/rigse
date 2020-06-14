class AddDomainMatchersToClient < ActiveRecord::Migration
  def change
    add_column :clients, :domain_matchers, :string
  end
end
