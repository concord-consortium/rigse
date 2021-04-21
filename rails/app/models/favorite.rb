class Favorite < ApplicationRecord

  belongs_to :favoritable, :polymorphic => true
  belongs_to :user

  validates :user_id, uniqueness: {
    scope:      [:favoritable_id, :favoritable_type],
    message:    'User can only favorite one item of a type.'
  }

end
