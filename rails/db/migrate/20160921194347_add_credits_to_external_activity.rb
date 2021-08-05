class AddCreditsToExternalActivity < ActiveRecord::Migration[5.1]
  def change
    add_column :external_activities, :credits, :string
  end
end
