class AddUpdatedAtToDiyModels < ActiveRecord::Migration
  def self.up
    add_column :diy_models, :updated_at, :datetime, :default => Time.now
  end

  def self.down
    remove_column :diy_models, :updated_at
  end
end
