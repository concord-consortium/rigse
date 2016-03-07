class AddHasBeenReviewedToSavables < ActiveRecord::Migration
  def change
      add_column :saveable_external_links, :has_been_reviewed, :boolean, :default => false
      add_column :saveable_image_questions, :has_been_reviewed, :boolean, :default => false
      add_column :saveable_multiple_choices, :has_been_reviewed, :boolean, :default => false
      add_column :saveable_open_responses, :has_been_reviewed, :boolean, :default => false

      remove_column :saveable_external_links, :no_written_feedback
      remove_column :saveable_image_questions, :no_written_feedback
      remove_column :saveable_multiple_choices, :no_written_feedback
      remove_column :saveable_open_responses, :no_written_feedback
  end
end
