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

end
