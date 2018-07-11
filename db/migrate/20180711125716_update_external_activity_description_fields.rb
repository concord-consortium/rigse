class UpdateExternalActivityDescriptionFields < ActiveRecord::Migration
  class ExternalActivity < ActiveRecord::Base
  end

  def up
    rename_column :external_activities, :description, :archived_description
    rename_column :external_activities, :description_for_teacher, :long_description_for_teacher
    rename_column :external_activities, :abstract, :short_description
    add_column :external_activities, :long_description, :text

    ExternalActivity.find_each(batch_size: 10) do |ea|
      # update_column shouldn't trigger any callbacks.
      if ea.long_description_for_teacher.present?
        # Copy old description_for_teachers to long_description
        ea.update_column('long_description', ea.long_description_for_teacher)
        # We could clear long_description_for_teacher value, but that would make this migration non-reversible.
        # ea.update_column('long_description_for_teacher', '')
      else
        # Otherwise, just use previous description value.
        ea.update_column('long_description', ea.archived_description)
      end
    end
  end

  def down
    rename_column :external_activities, :archived_description, :description
    rename_column :external_activities, :long_description_for_teacher, :description_for_teacher
    rename_column :external_activities, :short_description, :abstract
    remove_column :external_activities, :long_description
  end
end
