class Portal::Offering < ActiveRecord::Base
  set_table_name :portal_offerings
  
  acts_as_replicatable

  belongs_to :clazz, :class_name => "Portal::Clazz", :foreign_key => "clazz_id"
  belongs_to :runnable, :polymorphic => true
  
  has_many :learners, :class_name => "Portal::Learner", :foreign_key => "offering_id", :dependent => :destroy
  
  [:name, :description].each { |m| delegate m, :to => :runnable }
  
  def find_or_create_learner(student)
    learners.find_by_student_id(student) || learners.create(:student_id => student.id)
  end
  
  self.extend SearchableModel

  @@searchable_attributes = %w{status}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

    def display_name
      "Offering"
    end
  end
end