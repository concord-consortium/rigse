require File.join(File.dirname(__FILE__), "20090130033823_create_images.rb")
class ConvertImageToPaperclip < ActiveRecord::Migration
  def self.up
    CreateImages.down
    create_table :images do |t|
      t.integer           :user_id
      t.string            :name
      t.text              :attribution
      t.string            :publication_status, :default => 'draft'
      t.string            :image_file_name
      t.integer           :image_file_size
      t.string            :image_content_type
      t.datetime          :image_updated_at
      t.has_attached_file :image

      t.timestamps
    end
  end

  def self.down
    drop_table :images
    CreateImages.up
  end
end
