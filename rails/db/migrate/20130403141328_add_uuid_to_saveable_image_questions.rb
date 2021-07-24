class AddUuidToSaveableImageQuestions < ActiveRecord::Migration[5.1]
  def change
    add_column :saveable_image_questions, :uuid, :string, :limit => 36
  end
end
