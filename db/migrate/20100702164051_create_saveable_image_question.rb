class CreateSaveableImageQuestion < ActiveRecord::Migration
  def self.up
    create_table :saveable_image_questions do |t|
      t.integer     :learner_id
      t.integer     :offering_id
      t.integer     :image_question_id
      t.integer     :response_count, :default => 0
      t.timestamps
    end
    create_table :saveable_image_question_answers do |t|
      t.integer     :image_question_id
      t.integer     :bundle_content_id
      t.integer     :blob_id
      t.integer     :position
      t.timestamps
    end
    
    add_index  :saveable_image_questions, :offering_id
    add_index  :saveable_image_questions, :learner_id
    
    add_index :saveable_image_question_answers, [:image_question_id, :position], :name => 'i_q_id_and_position_index'
    
  end

  def self.down
    remove_index  :saveable_image_question_answers, :name => 'i_q_id_and_position_index'
    
    remove_index  :saveable_image_questions, :offering_id
    remove_index  :saveable_image_questions, :learner_id
    
    drop_table :saveable_image_question_answers
    drop_table :saveable_image_questions
  end
end
