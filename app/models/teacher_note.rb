class TeacherNote < ActiveRecord::Base
  belongs_to :user
  
  belongs_to :authored_entity, :polymorphic => true

  acts_as_replicatable
  include Changeable

  after_update :inform_investigation

  # send_update_events_to :investigation
  def inform_investigation
    self.authored_entity.investigation.touch
  end

end
