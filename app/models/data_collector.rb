class DataCollector < ActiveRecord::Base
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  
  has_one :probe_type
  
  acts_as_replicatable
  
  include Changeable

  default_value_for :name, "Data Collector"
  default_value_for :description, <<-HEREDOC
  A simple Data Collector graph.
  HEREDOC

  default_value_for :y_axis_min, 0
  default_value_for :y_axis_max, 5
  default_value_for :x_axis_min, 0
  default_value_for :x_axis_max, 60
  
end
