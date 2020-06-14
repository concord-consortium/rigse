class CreateLearnerProcessingEvents < ActiveRecord::Migration
  def change
    create_table :learner_processing_events do |t|
      t.references :learner
      t.datetime :portal_end
      t.datetime :portal_start
      t.datetime :lara_end
      t.datetime :lara_start
      t.integer :elapsed_seconds
      t.string :duration
      t.string :login
      t.string :teacher
      t.string :url

      t.timestamps
    end
    add_index :learner_processing_events, :learner_id
    add_index :learner_processing_events, :url
  end
end
