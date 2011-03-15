class StudentView < ActiveRecord::Base
  belongs_to :users
  belongs_to :viewable, :polymorphic => true
end
