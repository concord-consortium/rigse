class Xhtml < ActiveRecord::Base
  has_many :investigation_steps, :as => :step
  has_many :activities, :through =>:investigation_steps
end
