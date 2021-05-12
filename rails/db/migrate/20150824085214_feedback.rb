class Feedback < ActiveRecord::Migration[5.1]
  def change
    add_column :saveable_external_link_urls, :feedback, :text
    add_column :saveable_image_question_answers, :feedback, :text
    add_column :saveable_multiple_choice_answers, :feedback, :text
    add_column :saveable_open_response_answers, :feedback, :text
  end
end
