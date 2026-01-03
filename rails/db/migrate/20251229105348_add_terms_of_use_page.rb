class AddTermsOfUsePage < ActiveRecord::Migration[8.0]
  def change
    add_column :admin_settings, :terms_of_use_page_content, :text, :limit => 16777215, :null => true
  end
end
