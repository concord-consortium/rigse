class AddCreditsToExternalActivity < ActiveRecord::Migration
  def change
    add_column :external_activities, :credits, :string
  end
end
