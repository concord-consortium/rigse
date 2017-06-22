class StandardStatement < ActiveRecord::Base
  attr_accessible :description, :material_id, :material_type, :statement_label, :statement_notation, :uri
end
