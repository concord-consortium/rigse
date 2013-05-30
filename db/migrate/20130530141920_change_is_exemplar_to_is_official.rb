class ChangeIsExemplarToIsOfficial < ActiveRecord::Migration
  def change
    rename_column :external_activities, :is_exemplar, :is_official
  end
end
