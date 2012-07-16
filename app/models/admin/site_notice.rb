class Admin::SiteNotice < ActiveRecord::Base
  has_many :site_notice_roles
  has_many :site_notice_users
  validates :notice_html, :created_by, :presence => true
end
