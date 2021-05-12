class AddRubricUrlToExternalActivity < ActiveRecord::Migration[5.1]
  def change
    add_column :external_activities, :rubric_url, :string
  end
end
