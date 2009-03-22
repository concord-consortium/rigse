class DataCollector < ActiveRecord::Base
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  acts_as_replicatable

  default_value_for :name, "Data Collector"
  default_value_for :description, <<-HEREDOC
  A simple Data Collector Graph.
  HEREDOC
  
  default_value_for :content, <<-HEREDOC
perhaps some data ...
HEREDOC
end
