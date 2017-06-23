class StandardStatement < ActiveRecord::Base

  attr_accessible :uri

  attr_accessible :material_id
  attr_accessible :material_type

  attr_accessible :description
  attr_accessible :statement_label
  attr_accessible :statement_notation

end
