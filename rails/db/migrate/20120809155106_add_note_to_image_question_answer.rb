class AddNoteToImageQuestionAnswer < ActiveRecord::Migration[5.1]
  def change
    add_column :saveable_image_question_answers, :note, :text
  end
end
