class AddMaterialTypeToExternalActivity < ActiveRecord::Migration

  def change
    add_column :external_activities, :material_type, :string

    ExternalActivity.all.each do |external_activity|
        if ! external_activity.template_type.nil? &&
            ! external_activity.template_type.blank?
            external_activity.update_attributes(:material_type => external_activity.template_type)
        else
            external_activity.update_attributes(:material_type => 'Activity')
        end
    end

  end

end
