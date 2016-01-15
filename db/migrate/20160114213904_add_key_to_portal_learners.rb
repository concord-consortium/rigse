class AddKeyToPortalLearners < ActiveRecord::Migration
  def change
    add_column :portal_learners, :key, :string
    add_index :portal_learners, :key, name: 'index_portal_learners_on_key', unique: true
  end
end
