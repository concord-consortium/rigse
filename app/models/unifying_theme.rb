class UnifyingTheme < ActiveRecord::Base
  has_many :big_ideas
  has_many :assesment_targets
end
