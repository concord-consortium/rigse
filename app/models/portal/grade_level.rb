class Portal::GradeLevel < ActiveRecord::Base
  set_table_name :portal_grade_levels

  acts_as_replicatable

  belongs_to :grade, :class_name => "Portal::Grade", :foreign_key => "grade_id"
  belongs_to :has_grade_levels, :polymorphic => true
  # Schools, Teachers, Courses, Classes, and Students have_many grade_levels

  has_and_belongs_to_many :admin_project_settings

  delegate :name, :to => :grade

  include Changeable

  ## suport for searching and pagination:
  self.extend SearchableModel
  @@searchable_attributes = %w{status}
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

    def display_name
      "Grade Level"
    end
  end
end
