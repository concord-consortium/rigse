class Expectation < ActiveRecord::Base
  belongs_to :user
  belongs_to :expectation_stem
end
