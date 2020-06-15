class AddIsRequiredToEmbeddableOpenResponses < ActiveRecord::Migration
  def change
    add_column :embeddable_open_responses, :is_required, :boolean, :null => false, :default => false
  end
end
