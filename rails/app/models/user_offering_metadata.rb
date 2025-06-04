class UserOfferingMetadata < ApplicationRecord
  self.table_name = :user_offering_metadata

  belongs_to :user
  belongs_to :offering, :class_name => "Portal::Offering"
end
