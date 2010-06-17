class CreateEmbeddableImageQuestions < ActiveRecord::Migration
  def self.up
    create_table :embeddable_image_questions do |t|
      
      t.integer   "user_id"
      t.string    "uuid",        :limit => 36
      t.string    "name"
      t.text      "prompt"
      t.timestamps
    end
  end

  def self.down
    drop_table :embeddable_image_questions
  end
end
