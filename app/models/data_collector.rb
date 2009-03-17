class DataCollector < ActiveRecord::Base
  has_many :activity_steps, :as => :step
  has_many :activities, :through =>:activity_steps
end
