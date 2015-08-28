class Scoring < ActiveRecord::Migration
  def change
    add_column :saveable_external_links, :score, :integer
    add_column :saveable_image_questions, :score, :integer
    add_column :saveable_multiple_choices, :score, :integer
    add_column :saveable_open_responses, :score, :integer

  end
end
