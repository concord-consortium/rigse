class Role < ActiveRecord::Base

  has_and_belongs_to_many :users, options = {:join_table => "roles_users"}
  acts_as_list
  acts_as_replicatable
end
