class StandardStatement < ActiveRecord::Base

  #
  # Identifier for this statement
  #
  attr_accessible :uri

  #
  # Document this statement belongs to.
  #
  attr_accessible :doc

  #
  # associated material
  #
  attr_accessible :material_type
  attr_accessible :material_id

  #
  # statement fields
  #
  attr_accessible   :description
  serialize         :description

  attr_accessible   :statement_label
  attr_accessible   :statement_notation

  attr_accessible   :parents
  serialize         :parents

  attr_accessible   :education_level
  serialize         :education_level

  attr_accessible   :is_leaf

  def duplicate_and_assign_to(material_type, material_id)
    statement = StandardStatement.new(attributes.except('id', 'created_at', 'updated_at', 'material_type', 'material_id'))
    statement.material_type = material_type
    statement.material_id = material_id
    statement.save
  end
end
