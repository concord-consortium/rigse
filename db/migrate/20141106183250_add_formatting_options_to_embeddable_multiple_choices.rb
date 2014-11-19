class AddFormattingOptionsToEmbeddableMultipleChoices < ActiveRecord::Migration
  def self.up
    add_column :embeddable_multiple_choices, :is_likert, :boolean, :default => false
    add_column :embeddable_multiple_choices, :horizontal, :boolean, :default => false
  end

  def self.down
    remove_column :embeddable_multiple_choices, :horizontal
    remove_column :embeddable_multiple_choices, :is_likert
  end
end
