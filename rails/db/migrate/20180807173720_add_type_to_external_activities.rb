class AddTypeToExternalActivities < ActiveRecord::Migration
  class ExternalActivity < ApplicationRecord
  end

  def up
    add_column :external_activities, :source_type, :string, default: nil

    ExternalActivity.find_each(batch_size: 10) do |ea|
      # Look for LARA activities and set type correctly. LARA activity can be recognized easily
      # as it has a template and launch_url.
      if ea.template_id.present? && ea.launch_url.present?
        # update_column shouldn't trigger any callbacks.
        ea.update_column('source_type', 'LARA')
      end
    end
  end

  def down
    remove_column :external_activities, :source_type
  end
end
