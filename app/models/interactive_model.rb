class InteractiveModel < ActiveRecord::Base
  has_many :activity_steps, :as => :step
  has_many :activities, :through =>:activity_steps
  
  acts_as_replicatable
  
  include Changeable
  
end
