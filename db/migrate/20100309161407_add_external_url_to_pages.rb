class AddExternalUrlToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :external_url, :string
  end

  def self.down
    remove_column :pages, :external_url
  end
end
