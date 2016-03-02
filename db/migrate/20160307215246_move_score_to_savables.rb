class MoveScoreToSavables < ActiveRecord::Migration

  def change
    add_column :saveable_external_link_urls, :score, :integer
    add_column :saveable_image_question_answers, :score, :integer
    add_column :saveable_multiple_choice_answers, :score, :integer
    add_column :saveable_open_response_answers, :score, :integer

    remove_column :saveable_external_links, :score
    remove_column :saveable_image_questions, :score
    remove_column :saveable_multiple_choices, :score
    remove_column :saveable_open_responses, :score
  end

end
