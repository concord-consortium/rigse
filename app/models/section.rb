class Section < ActiveRecord::Base
  belongs_to :investigatation
  belongs_to :user
  has_many :pages, :order => :position, :dependent => :destroy
  acts_as_list :scope => :investigation_id
end
