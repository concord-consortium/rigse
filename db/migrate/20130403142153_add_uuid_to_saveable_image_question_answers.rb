class AddUuidToSaveableImageQuestionAnswers < ActiveRecord::Migration
  def change
    add_column :saveable_image_question_answers, :uuid, :string, :limit => 36 
  end
end
