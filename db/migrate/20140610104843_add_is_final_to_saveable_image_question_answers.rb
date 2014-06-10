class AddIsFinalToSaveableImageQuestionAnswers < ActiveRecord::Migration
  def change
    add_column :saveable_image_question_answers, :is_final, :boolean
  end
end
