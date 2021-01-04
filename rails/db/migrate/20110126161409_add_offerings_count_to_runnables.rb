class AddOfferingsCountToRunnables < ActiveRecord::Migration
  def self.up
    add_column :investigations, :offerings_count, :integer, :default => 0
    add_column :resource_pages, :offerings_count, :integer, :default => 0
    add_column :pages, :offerings_count, :integer, :default => 0
    add_column :portal_teachers, :offerings_count, :integer, :default => 0
    
  end

  def self.down
    remove_column :investigations, :offerings_count
    remove_column :resource_pages, :offerings_count
    remove_column :pages, :offerings_count
    remove_column :portal_teachers, :offerings_count
  end
end
