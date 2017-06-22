class StandardDocument < ActiveRecord::Base

  has_many: standard_statements

  attr_accessible :title, :uri

end
