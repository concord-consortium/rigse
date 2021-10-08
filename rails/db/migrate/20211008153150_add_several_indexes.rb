class AddSeveralIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :saveable_interactives, :learner_id
    add_index :access_grants, [:code, :client_id]
    add_index :access_grants, :access_token_expires_at
  end
end
