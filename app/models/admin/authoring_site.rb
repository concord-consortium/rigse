class Admin::AuthoringSite < ActiveRecord::Base
  self.table_name = 'authoring_sites'
  attr_accessible :name, :url
end
