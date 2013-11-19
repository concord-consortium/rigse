class AddDrawingPromptToImageQuestions < ActiveRecord::Migration
  def change
    add_column :embeddable_image_questions, :drawing_prompt, :text
  end
end
