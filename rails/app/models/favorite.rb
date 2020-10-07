class Favorite < ActiveRecord::Base

  belongs_to :favoritable, :polymorphic => true
  belongs_to :user

  attr_accessible :user, :user_id, :favoritable, :favoritable_id, :favoritable_type

  validates :user_id, uniqueness: {
    scope:      [:favoritable_id, :favoritable_type],
    message:    'User can only favorite one item of a type.'
  }

end
