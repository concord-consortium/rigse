class AddRationaleAndMultiSelectToMultipleChoice < ActiveRecord::Migration
  def change
    add_column :embeddable_multiple_choices, :enable_rationale, :boolean, :default => false
    add_column :embeddable_multiple_choices, :rationale_prompt, :text
    add_column :embeddable_multiple_choices, :allow_multiple_selection, :boolean, :default => false
  end
end
