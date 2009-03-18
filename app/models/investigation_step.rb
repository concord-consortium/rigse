class InvestigationStep < ActiveRecord::Base
  belongs_to :investigation
  belongs_to :step,   :polymorphic => true
end
