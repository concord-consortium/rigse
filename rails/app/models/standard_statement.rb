class StandardStatement < ActiveRecord::Base

  #
  # Identifier for this statement
  #
  attr_accessible :uri, :doc, :material_type, :material_id, :material, :description, :statement_label, :statement_notation, :parents, :education_level, :is_leaf

  serialize :description, :parents, :education_level


  def duplicate_and_assign_to(material_type, material_id)
    statement = StandardStatement.new(attributes.except('id', 'created_at', 'updated_at', 'material_type', 'material_id'))
    statement.material_type = material_type
    statement.material_id = material_id
    statement.save
  end
end
