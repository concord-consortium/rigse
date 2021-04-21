class Portal::Subject < ApplicationRecord
  self.table_name = :portal_subjects

  acts_as_replicatable

  belongs_to :teacher, :class_name => "Portal::Teacher", :foreign_key => "teacher_id"

  self.extend SearchableModel

  @@searchable_attributes = %w{name description}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

  end
end
