class AddNoteToImageQuestionAnswer < ActiveRecord::Migration
  def change
    add_column :saveable_image_question_answers, :note, :text
  end
end
