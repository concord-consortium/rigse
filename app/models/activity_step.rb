class ActivityStep < ActiveRecord::Base
belongs_to :activity
  belongs_to :step,   :polymorphic => true
end
