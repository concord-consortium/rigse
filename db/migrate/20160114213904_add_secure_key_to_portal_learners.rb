class AddSecureKeyToPortalLearners < ActiveRecord::Migration
  def change
    add_column :portal_learners, :secure_key, :string
    add_index :portal_learners, :secure_key, name: 'index_portal_learners_on_sec_key', unique: true
  end
end
