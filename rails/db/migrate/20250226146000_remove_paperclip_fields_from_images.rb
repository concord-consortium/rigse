class RemovePaperclipFieldsFromImages < ActiveRecord::Migration[7.0]
  def change
    remove_column :images, :image_file_name, :string
    remove_column :images, :image_content_type, :string
    remove_column :images, :image_file_size, :integer
    remove_column :images, :image_updated_at, :datetime
  end
end
