class AddRubricUrlToExternalActivity < ActiveRecord::Migration
  def change
    add_column :external_activities, :rubric_url, :string
  end
end
