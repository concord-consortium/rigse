class Xhtml < ActiveRecord::Base
  has_many :investigation_steps, :as => :step
  has_many :investigations, :through =>:investigation_steps
end
