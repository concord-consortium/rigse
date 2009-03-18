class InteractiveModel < ActiveRecord::Base
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  acts_as_list
end
