class Admin::Cohort < ActiveRecord::Base
  self.table_name = 'admin_cohorts'
  belongs_to :project, :class_name => 'Admin::Project'
  has_many :items, :class_name => 'Admin::CohortItem', :foreign_key => "admin_cohort_id"

  def teachers
    items.where(:item_type => 'Portal::Teacher')
  end

  def fullname
    "#{project.name}: #{name}"
  end
end
