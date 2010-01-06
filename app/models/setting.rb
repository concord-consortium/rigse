class Setting < ActiveRecord::Base
    belongs_to :scope, :polymorphic => true
    
end
