class CreateRunsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :portal_runs, id: :primary_key do |t|
      t.datetime :start_time, null: false
      t.integer :learner_id, null: false
      t.foreign_key :portal_learners, column: :learner_id
      # No default timestamps (created_at, updated_at)
    end
  end
end
