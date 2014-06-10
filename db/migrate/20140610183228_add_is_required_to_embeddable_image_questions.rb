class AddIsRequiredToEmbeddableImageQuestions < ActiveRecord::Migration
  def change
    add_column :embeddable_image_questions, :is_required, :boolean, :null => false, :default => false
  end
end
