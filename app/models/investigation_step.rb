class InvestigationStep < ActiveRecord::Base
belongs_to :investigationbelongs_to :step,   :polymorphic => true

end
