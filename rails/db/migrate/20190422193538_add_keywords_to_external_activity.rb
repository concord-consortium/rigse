class AddKeywordsToExternalActivity < ActiveRecord::Migration[5.1]
  def change
    add_column :external_activities, :keywords, :text
  end
end
