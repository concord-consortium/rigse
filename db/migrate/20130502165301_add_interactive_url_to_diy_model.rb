class AddInteractiveUrlToDiyModel < ActiveRecord::Migration
  def self.up
    add_column :diy_models, :interactive_url, :string
  end

  def self.down
    remove_column :diy_models, :interactive_url
  end
end
