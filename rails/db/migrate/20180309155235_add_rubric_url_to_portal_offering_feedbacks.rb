class AddRubricUrlToPortalOfferingFeedbacks < ActiveRecord::Migration[5.1]
  def change
    add_column :portal_offering_activity_feedbacks, :rubric_url, :string
    add_column :portal_offering_activity_feedbacks, :use_rubric, :boolean
    add_column :portal_offering_activity_feedbacks, :rubric, :text
  end
end
