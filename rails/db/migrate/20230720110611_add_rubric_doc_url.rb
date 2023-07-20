class AddRubricDocUrl < ActiveRecord::Migration[6.1]
  def change
    add_column :external_activities, :rubric_doc_url, :string
  end
end
