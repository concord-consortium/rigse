class AddTeacherGuidePage < ActiveRecord::Migration[8.0]
  def change
    add_column :admin_settings, :teacher_guide_type, :string, default: 'custom html'
    add_column :admin_settings, :teacher_guide_page_content, :text, :limit => 16777215, :null => true
    add_column :admin_settings, :teacher_guide_external_url, :string
  end
end
