class Portal::OfferingEmbeddableMetadata < ActiveRecord::Base
  self.table_name = :portal_offering_embeddable_metadata

  belongs_to :offering, :class_name => "Portal::Offering"
  belongs_to :embeddable, :polymorphic => true

end
