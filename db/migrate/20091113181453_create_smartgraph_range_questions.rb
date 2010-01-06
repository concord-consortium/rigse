class CreateSmartgraphRangeQuestions < ActiveRecord::Migration
  def self.up
    create_table :smartgraph_range_questions do |t|
      
      t.integer   "user_id"
      t.string    "uuid",        :limit => 36
      t.string    "name"
      t.text      "description"
      
      t.integer :data_collector_id
      t.integer :correct_range_min
      t.integer :correct_range_max
      t.string  :correct_range_axis
      t.integer :highlight_range_min
      t.integer :highlight_range_max
      t.string  :highlight_range_axis
      t.text    :prompt
      t.string  :answer_style
      t.text    :no_answer_response_text
      t.boolean :no_answer_highlight
      t.text    :correct_response_text
      t.boolean :correct_highlight
      t.text    :first_wrong_answer_response_text
      t.boolean :first_wrong_highlight
      t.text    :second_wrong_answer_response_text
      t.boolean :second_wrong_highlight
      t.text    :multiple_wrong_answers_response_text
      t.boolean :multiple_wrong_highlight

      t.timestamps
    end
  end

  def self.down
    drop_table :smartgraph_range_questions
  end
end
