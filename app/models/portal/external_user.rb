class Portal::ExternalUser < ActiveRecord::Base
  set_table_name :portal_external_user
  
  belongs_to :external_user_domain
  belongs_to :user
  
  acts_as_replicatable
  
end
