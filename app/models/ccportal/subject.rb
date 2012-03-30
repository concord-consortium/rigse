class Ccportal::Subject < Ccportal::Ccportal
  self.table_name = :portal_subjects
  self.primary_key = :subject_id
  
  has_many :activities, :foreign_key => :activity_subject, :class_name => 'Ccportal::Activity'
end
