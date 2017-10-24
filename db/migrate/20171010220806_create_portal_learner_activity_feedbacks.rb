class CreatePortalLearnerActivityFeedbacks < ActiveRecord::Migration
  def change
    create_table :portal_learner_activity_feedbacks do |t|
      t.text :text_feedback
      t.integer :score, default: 10
      t.boolean :has_been_reviewed, default: false
      t.references :portal_learner
      t.references :activity_feedback

      t.timestamps
    end
    add_index :portal_learner_activity_feedbacks, :portal_learner_id
    add_index :portal_learner_activity_feedbacks, :activity_feedback_id
  end
end
