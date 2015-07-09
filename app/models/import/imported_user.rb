class Import::ImportedUser < ActiveRecord::Base
  self.table_name = :imported_users
  attr_accessible :user_url,:is_verified,:importing_domain,:import_id

  belongs_to :user, :class_name => "User", :foreign_key => "user_id", :inverse_of => :imported_user
  belongs_to :importing_portal

end