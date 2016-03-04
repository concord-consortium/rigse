class Scoring < ActiveRecord::Migration
  def change
    add_column :saveable_external_links, :score, :integer
    add_column :saveable_image_questions, :score, :integer
    add_column :saveable_multiple_choices, :score, :integer
    add_column :saveable_open_responses, :score, :integer

    create_table "portal_offering_embeddable_metadata" do |t|
      t.integer  "offering_id"
      t.integer  "embeddable_id"
      t.string   "embeddable_type"
      t.boolean  "enable_score",  :default => false
      t.integer  "max_score"
      t.timestamps
    end

    add_index "portal_offering_embeddable_metadata", ["offering_id", "embeddable_id", "embeddable_type"], :name => "index_portal_offering_metadata", :unique => true
  end
end
