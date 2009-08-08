class Portal::Offering < ActiveRecord::Base
  set_table_name :portal_offerings
  
  acts_as_replicatable
  
  has_one :sds_config, :class_name => "Portal::SdsConfig", :as => :configurable

  belongs_to :clazz, :class_name => "Portal::Clazz", :foreign_key => "clazz_id"
  belongs_to :runnable, :polymorphic => true
  
  has_many :learners, :class_name => "Portal::Learner", :foreign_key => "offering_id"
  
  [:name, :description].each { |m| delegate m, :to => :runnable }
  
  def find_or_create_learner(student)
    learners.find_by_student_id(student) || learners.create(:student_id => student.id)
  end
  
end