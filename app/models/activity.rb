class Activity < ActiveRecord::Base
  belongs_to :user
 acts_as_replicatable
end