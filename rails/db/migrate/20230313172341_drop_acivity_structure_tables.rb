class DropAcivityStructureTables < ActiveRecord::Migration[6.1]
  def up
    drop_table :investigations
    drop_table :activities
    drop_table :pages
    drop_table :page_elements
    drop_table :sections
    drop_table :embeddable_iframes
    drop_table :embeddable_image_questions
    drop_table :embeddable_multiple_choices
    drop_table :embeddable_multiple_choice_choices
    drop_table :embeddable_open_responses
    drop_table :saveable_external_links
    drop_table :saveable_image_questions
    drop_table :saveable_interactives
    drop_table :saveable_multiple_choices
    drop_table :saveable_open_responses
    drop_table :report_embeddable_filters
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
