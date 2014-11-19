class AddMultipleSelectionToEmbeddableMultipleChoices < ActiveRecord::Migration
  def self.up
    add_column :embeddable_multiple_choices, :allow_multiple_selection, :boolean, :default => false
  end

  def self.down
    remove_column :embeddable_multiple_choices, :allow_multiple_selection
  end
end
