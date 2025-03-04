class Admin::AuthoringSite < ApplicationRecord
  self.table_name = 'authoring_sites'

  # validates :name, presence: { message: "Name can't be blank" }
  # validates :url, presence: { message: "URL can't be blank" }
end
