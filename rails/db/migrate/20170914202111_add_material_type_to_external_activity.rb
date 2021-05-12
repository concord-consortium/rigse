class AddMaterialTypeToExternalActivity < ActiveRecord::Migration[5.1]

  class ExternalActivity < ApplicationRecord
    self.table_name = 'external_activities'
  end

  def change
    add_column :external_activities, :material_type, :string, :default => 'Activity'

    ExternalActivity.where('template_type is null').update_all(material_type: 'Activity')
    ExternalActivity.where(template_type: 'Activity').update_all(material_type: 'Activity')
    ExternalActivity.where(template_type: 'Investigation').update_all(material_type: 'Investigation')

  end

end
