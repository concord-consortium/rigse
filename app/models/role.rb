class Role < ActiveRecord::Base

  has_many :admin_site_notice_roles, :dependent => :destroy, :class_name => 'Admin::SiteNoticeRole', :foreign_key => 'role_id', :primary_key => 'id'
  has_and_belongs_to_many :users, :uniq => true, :join_table => "roles_users"
  acts_as_list
  acts_as_replicatable

  default_scope :order => 'position ASC'

end
