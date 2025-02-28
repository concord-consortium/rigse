class MigratePaperclipImagesToActiveStorage < ActiveRecord::Migration[7.0]
  def up
    return unless ActiveRecord::Base.connection.table_exists?(:active_storage_blobs)

    Image.find_each do |image|
      next unless image.image_file_name.present?

      # Attach existing Paperclip file to Active Storage
      image.image.attach(
        io: File.open(Rails.root.join("public", "system", "images", image.id.to_s, "original", image.image_file_name)),
        filename: image.image_file_name,
        content_type: image.image_content_type
      )
    end
  end

  def down
    # No going back
  end
end
