class BigIdea < ActiveRecord::Base
  belongs_to :user
  belongs_to :unifying_theme
  acts_as_replicatable
end
