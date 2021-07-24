class AddUrlToPage < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :url, :text
  end
end
