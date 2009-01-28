class BigIdea < ActiveRecord::Base
  belongs_to :user
  belongs_to :unifying_theme
end
