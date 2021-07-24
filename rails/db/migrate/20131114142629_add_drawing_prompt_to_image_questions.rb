class AddDrawingPromptToImageQuestions < ActiveRecord::Migration[5.1]
  def change
    add_column :embeddable_image_questions, :drawing_prompt, :text
  end
end
