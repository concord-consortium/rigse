# This migration comes from lightweight (originally 20120826214946)
class CreateLightweightQuestionItems < ActiveRecord::Migration
  def change
    create_table :lightweight_question_items do |t|
      t.integer :interactive_page_id
      t.integer :question_id
      t.string :question_type
      t.integer :position

      t.timestamps
    end
  end
end
