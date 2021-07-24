class StandardStatement < ApplicationRecord

  serialize :description
  serialize :parents
  serialize :education_level

  def duplicate_and_assign_to(material_type, material_id)
    statement = StandardStatement.new(attributes.except('id', 'created_at', 'updated_at', 'material_type', 'material_id'))
    statement.material_type = material_type
    statement.material_id = material_id
    statement.save
  end
end
