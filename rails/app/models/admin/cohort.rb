class Admin::Cohort < ApplicationRecord
  self.table_name = 'admin_cohorts'
  belongs_to :project, :class_name => 'Admin::Project'
  has_many :items, :class_name => 'Admin::CohortItem', :foreign_key => "admin_cohort_id", :dependent => :destroy

  validates_presence_of :name, message: "can't be blank"
  self.extend SearchableModel

  class <<self
    def searchable_attributes
      %w{name}
    end
  end

  def teachers
    items.where(:item_type => 'Portal::Teacher').map {|i| Portal::Teacher.find_by_id(i.item_id)}.to_a.flatten.uniq.compact
  end

  def students
    teachers.map {|t| t.students}.flatten.uniq
  end

  def fullname
    project ? "#{project.name}: #{name}" : name
  end
end
