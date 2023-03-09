class DropAnswerTables < ActiveRecord::Migration[6.1]
  def up
    drop_table :saveable_image_question_answers
    drop_table :saveable_multiple_choice_answers
    drop_table :saveable_multiple_choice_rationale_choices
    drop_table :saveable_open_response_answers
    drop_table :saveable_external_link_urls
    drop_table :saveable_interactive_states
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
