class Portal::Run < ApplicationRecord

    self.table_name = :portal_runs

    # Associations
    belongs_to :portal_learner, class_name: "Portal::Learner", foreign_key: "learner_id"
  
    # Validations
    validates :start_time, presence: true
  end