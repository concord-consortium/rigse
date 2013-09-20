class AddLightweightToPageAndActivity < ActiveRecord::Migration
  def self.up
    add_column :embeddable_diy_models, :lightweight, :boolean, :default => false
    add_column :pages, :lightweight, :boolean, :default => false
    add_column :activities, :lightweight, :boolean, :default => false
  end

  def self.down
    remove_column :embeddable_diy_models, :lightweight
    remove_column :pages, :lightweight
    remove_column :activities, :lightweight
  end
end
