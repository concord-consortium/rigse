class Portal::ExternalUserDomain < ActiveRecord::Base
  set_table_name :portal_external_user_domains
  
  has_many :external_users
  
  acts_as_replicatable
  
  validates_format_of :server_url, :with => URI::regexp(%w(http https))
  validates_length_of :name, :minimum => 1
  
end
