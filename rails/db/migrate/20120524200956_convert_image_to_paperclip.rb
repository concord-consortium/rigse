require File.join(File.dirname(__FILE__), "20090130033823_create_images.rb")
class ConvertImageToPaperclip < ActiveRecord::Migration
  def self.up
    create_table :images, :force => true do |t|
      t.integer           :user_id
      t.string            :name
      t.text              :attribution
      t.string            :publication_status, :default => 'draft'

      t.timestamps
    end
    add_attachment :images, :image
  end

  def self.down
    drop_table :images
  end
end
