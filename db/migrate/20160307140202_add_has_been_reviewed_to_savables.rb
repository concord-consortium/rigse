class AddHasBeenReviewedToSavables < ActiveRecord::Migration
  def up
      add_column :saveable_external_link_urls, :has_been_reviewed, :boolean, :default => false
      add_column :saveable_image_question_answers, :has_been_reviewed, :boolean, :default => false
      add_column :saveable_multiple_choice_answers, :has_been_reviewed, :boolean, :default => false
      add_column :saveable_open_response_answers, :has_been_reviewed, :boolean, :default => false

      remove_column :saveable_external_links, :no_written_feedback
      remove_column :saveable_image_questions, :no_written_feedback
      remove_column :saveable_multiple_choices, :no_written_feedback
      remove_column :saveable_open_responses, :no_written_feedback
  end

  def down
    add_column :saveable_external_links, :no_written_feedback, :boolean, :default => false
    add_column :saveable_image_questions, :no_written_feedback, :boolean, :default => false
    add_column :saveable_multiple_choices, :no_written_feedback, :boolean, :default => false
    add_column :saveable_open_responses, :no_written_feedback, :boolean, :default => false

    remove_column :saveable_external_link_urls, :has_been_reviewed
    remove_column :saveable_image_question_answers, :has_been_reviewed
    remove_column :saveable_multiple_choice_answers, :has_been_reviewed
    remove_column :saveable_open_response_answers, :has_been_reviewed
  end
end
