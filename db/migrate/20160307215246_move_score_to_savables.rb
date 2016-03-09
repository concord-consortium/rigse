class MoveScoreToSavables < ActiveRecord::Migration

  def up
    add_column :saveable_external_link_urls, :score, :integer
    add_column :saveable_image_question_answers, :score, :integer
    add_column :saveable_multiple_choice_answers, :score, :integer
    add_column :saveable_open_response_answers, :score, :integer

    remove_column :saveable_external_links, :score
    remove_column :saveable_image_questions, :score
    remove_column :saveable_multiple_choices, :score
    remove_column :saveable_open_responses, :score
  end

  def down
    add_column :saveable_external_links, :score, :integer
    add_column :saveable_image_questions, :score, :integer
    add_column :saveable_multiple_choices, :score, :integer
    add_column :saveable_open_responses, :score, :integer

    remove_column :saveable_external_link_urls, :score
    remove_column :saveable_image_question_answers, :score
    remove_column :saveable_multiple_choice_answers, :score
    remove_column :saveable_open_response_answers, :score
  end

end
