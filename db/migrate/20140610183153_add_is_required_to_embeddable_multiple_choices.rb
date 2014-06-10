class AddIsRequiredToEmbeddableMultipleChoices < ActiveRecord::Migration
  def change
    add_column :embeddable_multiple_choices, :is_required, :boolean, :null => false, :default => false
  end
end
