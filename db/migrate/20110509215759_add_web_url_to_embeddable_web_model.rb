class AddWebUrlToEmbeddableWebModel < ActiveRecord::Migration
  def self.up
    add_column :embeddable_web_models, :web_content_url, :text
    add_column :embeddable_web_models, :use_custom_url, :boolean, :default => false
  end

  def self.down
    remove_column :embeddable_web_models, :web_content_url
    remove_column :embeddable_web_models, :use_custom_url
  end
end
