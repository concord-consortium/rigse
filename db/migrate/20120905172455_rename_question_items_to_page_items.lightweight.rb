# This migration comes from lightweight (originally 20120831185540)
class RenameQuestionItemsToPageItems < ActiveRecord::Migration
  def change
    rename_table :lightweight_question_items, :lightweight_page_items

    rename_column :lightweight_page_items, :question_id, :embeddable_id
    rename_column :lightweight_page_items, :question_type, :embeddable_type
  end
end
