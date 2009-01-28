class UnifyingTheme < ActiveRecord::Base
  belongs_to :user
  has_many :big_ideas
  has_many :assesment_targets
end
