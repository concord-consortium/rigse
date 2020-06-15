class AddKeywordsToExternalActivity < ActiveRecord::Migration
  def change
    add_column :external_activities, :keywords, :text
  end
end
