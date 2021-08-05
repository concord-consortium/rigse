class Import::ImportedUser < ApplicationRecord
  self.table_name = :imported_users

  belongs_to :user, :class_name => "User", :foreign_key => "user_id", :inverse_of => :imported_user
  belongs_to :importing_portal

end