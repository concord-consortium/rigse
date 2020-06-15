class AddLearnerIdToAccessGrants < ActiveRecord::Migration
  def change
    add_column :access_grants, :learner_id, :integer
    add_index :access_grants, :learner_id
  end
end
