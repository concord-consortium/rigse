class AddUuidToSaveableImageQuestions < ActiveRecord::Migration
  def change
    add_column :saveable_image_questions, :uuid, :string, :limit => 36
  end
end
