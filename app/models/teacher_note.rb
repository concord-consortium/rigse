class TeacherNote < ActiveRecord::Base
  belongs_to :user
  # has_and_belongs_to_many :grade_span_expectations, :class_name => 'RiGse::GradeSpanExpectation', :join_table => "teacher_notes_grade_spans"
  # has_and_belongs_to_many :domains, :class_name => 'RiGse::Domain', :join_table => "teacher_notes_domains"
  # has_and_belongs_to_many :unifying_themes, :class_name => 'RiGse::UnifyingTheme', :join_table => "teacher_notes_unifying_themes"
  
  belongs_to :authored_entity, :polymorphic => true

  acts_as_replicatable
  include Changeable
  
  after_update :inform_investigation

  # send_update_events_to :investigation
  def inform_investigation
    self.authored_entity.investigation.touch
  end

end
