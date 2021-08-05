class AddIsFeaturedToInvestigations < ActiveRecord::Migration[5.1]
  def change
    add_column :investigations, :is_featured, :boolean, :default => false
  end
end
