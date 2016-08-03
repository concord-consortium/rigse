class Portal::OfferingEmbeddableMetadata < ActiveRecord::Base
  # t.boolean  "enable_score",         :default => false
  # t.integer  "max_score"
  # t.boolean  "enable_text_feedback", :default => true
  self.table_name = :portal_offering_embeddable_metadata

  belongs_to :offering, :class_name => "Portal::Offering"
  belongs_to :embeddable, :polymorphic => true

end
