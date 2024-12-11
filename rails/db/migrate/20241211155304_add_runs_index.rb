class AddRunsIndex < ActiveRecord::Migration[6.1]
  def change
    add_index :portal_runs, :start_time
  end
end
