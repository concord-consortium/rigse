class RemoveRubricUrlFromOfferingActivityFeedbacks < ActiveRecord::Migration
  def up
    remove_column :portal_offering_activity_feedbacks, :rubric_url
  end

  def down
    add_column :portal_offering_activity_feedbacks, :rubric_url, :string
  end
end
