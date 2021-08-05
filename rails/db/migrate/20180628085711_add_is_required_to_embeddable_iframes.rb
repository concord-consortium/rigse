class AddIsRequiredToEmbeddableIframes < ActiveRecord::Migration[5.1]
  def change
    add_column :embeddable_iframes, :is_required, :boolean, :default => false
  end
end
