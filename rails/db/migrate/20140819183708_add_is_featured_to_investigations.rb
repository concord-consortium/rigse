class AddIsFeaturedToInvestigations < ActiveRecord::Migration
  def change
    add_column :investigations, :is_featured, :boolean, :default => false
  end
end
