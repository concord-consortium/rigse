class DataCollector < ActiveRecord::Base
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
end
