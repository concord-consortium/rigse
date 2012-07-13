class Report::LearnerActivity < ActiveRecord::Base
  self.table_name = "report_learner_activity"
  
  belongs_to :learner, :class_name => "Portal::Learner", :foreign_key => "learner_id"
  belongs_to :activity, :class_name => "Activity", :foreign_key => "activity_id"
  
  validates_uniqueness_of :learner_id, :scope=> :activity_id
  
end
