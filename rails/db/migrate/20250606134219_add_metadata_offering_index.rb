class AddMetadataOfferingIndex < ActiveRecord::Migration[8.0]
  def change
    add_index :user_offering_metadata, :offering_id
  end
end
