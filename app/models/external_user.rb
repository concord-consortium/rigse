class ExternalUser < User
  
  belongs_to :external_user_domain
  
  acts_as_replicatable
  
end
