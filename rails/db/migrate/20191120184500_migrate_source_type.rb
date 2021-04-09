class MigrateSourceType < ActiveRecord::Migration
  class Tool < ApplicationRecord
  end

  class ExternalActivity < ApplicationRecord
  end

  def up
    tool = Tool.where(source_type: 'LARA').first
    tool = tool ? tool : Tool.create(name: 'LARA', source_type: 'LARA')
    ExternalActivity.where(source_type: 'LARA').update_all(tool_id: tool.id)
    remove_column :external_activities, :source_type
  end

  def down
    add_column :external_activities, :source_type, :string, default: nil
    tool = Tool.where(source_type: 'LARA').first
    if tool
      ExternalActivity.where(tool_id: tool.id).update_all(source_type: 'LARA')
    end
  end
end
