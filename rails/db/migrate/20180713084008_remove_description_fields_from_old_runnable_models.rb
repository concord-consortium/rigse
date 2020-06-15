class RemoveDescriptionFieldsFromOldRunnableModels < ActiveRecord::Migration
  def up
    remove_column :activities, :description_for_teacher
    remove_column :investigations, :description_for_teacher
  end

  def down
    add_column :activities, :description_for_teacher, :text
    add_column :investigations, :description_for_teacher, :text
  end
end
