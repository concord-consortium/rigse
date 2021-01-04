class AddIsRequiredToEmbeddableIframes < ActiveRecord::Migration
  def change
    add_column :embeddable_iframes, :is_required, :boolean, :default => false
  end
end
