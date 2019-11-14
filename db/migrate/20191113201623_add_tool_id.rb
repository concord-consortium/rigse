class AddToolId < ActiveRecord::Migration
  def change
    add_column :external_activities, :tool_id, :text
  end
end
