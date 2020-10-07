class Role < ActiveRecord::Base

  attr_accessible :title, :position, :uuid

  has_and_belongs_to_many :users, -> { uniq }, :join_table => "roles_users"
  acts_as_list
  acts_as_replicatable

  default_scope { order('position ASC') }

end
