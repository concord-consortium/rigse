class AddTimesStampsToEmbeddableXhtmls < ActiveRecord::Migration

  def self.up
    add_column :embeddable_xhtmls, :created_at, :datetime
    add_column :embeddable_xhtmls, :updated_at, :datetime
  end

  def self.down
    remove_column :embeddable_xhtmls, :created_at
    remove_column :embeddable_xhtmls, :updated_at
  end

end
