class Ancestry < ActiveRecord::Base
    belongs_to :ancestor, :polymorphic => true
    belongs_to :descendant, :polymorphic => true
end