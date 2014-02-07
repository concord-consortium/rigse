class AddInteractiveAttributesToDiyModel < ActiveRecord::Migration
  def self.up
    add_column :diy_models, :interactive_scale,  :string,  :default => "1.0"
    add_column :diy_models, :interactive_width,  :integer, :default => 690
    add_column :diy_models, :interactive_height, :integer, :default => 400
  end

  def self.down
    remove_column :diy_models, :interactive_scale
    remove_column :diy_models, :interactive_width
    remove_column :diy_models, :interactive_height
  end
end
