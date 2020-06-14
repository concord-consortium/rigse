class CreatePortalOfferingActivityFeedbacks < ActiveRecord::Migration
  def change
    create_table :portal_offering_activity_feedbacks do |t|
      t.boolean :enable_text_feedback, default: false
      t.integer :max_score, default: 10
      t.string  :score_type, default: "none"
      t.references :activity, index: true, foreign_key: true
      t.references :portal_offering, index: true, foreign_key: true
      t.timestamps
    end
  end
end
