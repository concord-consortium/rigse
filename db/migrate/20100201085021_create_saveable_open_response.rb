class CreateSaveableOpenResponse < ActiveRecord::Migration
  def self.up
    create_table :saveable_open_responses do |t|
      t.integer     :learner_id
      t.integer     :open_response_id
      t.timestamps
    end
    create_table :saveable_open_response_answers do |t|
      t.integer     :open_response_id
      t.integer     :bundle_content_id
      t.integer     :position
      t.text        :answer
      t.timestamps
    end
    
  end

  def self.down
    drop_table :saveable_open_response_answers
    drop_table :saveable_open_responses
  end
end
