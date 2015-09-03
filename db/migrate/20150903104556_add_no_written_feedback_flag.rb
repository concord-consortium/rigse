class AddNoWrittenFeedbackFlag < ActiveRecord::Migration
  def change
    add_column :saveable_external_links, :no_written_feedback, :boolean, :default => false
    add_column :saveable_image_questions, :no_written_feedback, :boolean, :default => false
    add_column :saveable_multiple_choices, :no_written_feedback, :boolean, :default => false
    add_column :saveable_open_responses, :no_written_feedback, :boolean, :default => false
  end
end
