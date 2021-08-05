class CreatePortalLearnerActivityFeedbacks < ActiveRecord::Migration[5.1]
  def change
    create_table :portal_learner_activity_feedbacks do |t|
      t.text :text_feedback
      t.integer :score, default: 10
      t.boolean :has_been_reviewed, default: false
      t.references :portal_learner
      t.references :activity_feedback

      t.timestamps
    end

  end
end
