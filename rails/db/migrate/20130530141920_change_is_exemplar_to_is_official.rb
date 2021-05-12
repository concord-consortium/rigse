class ChangeIsExemplarToIsOfficial < ActiveRecord::Migration[5.1]
  def change
    rename_column :external_activities, :is_exemplar, :is_official
  end
end
