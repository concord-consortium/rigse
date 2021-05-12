class IncreaseEmbeddableIframesUrlLengthLimit < ActiveRecord::Migration[5.1]
  def up
    change_column :embeddable_iframes, :url, :text
  end
  
  def down
    change_column :embeddable_iframes, :url, :string, :limit => 255
  end
end
