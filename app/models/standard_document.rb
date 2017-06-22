class StandardDocument < ActiveRecord::Base
  attr_accessible :jurisdiction, :name, :title, :uri
end
