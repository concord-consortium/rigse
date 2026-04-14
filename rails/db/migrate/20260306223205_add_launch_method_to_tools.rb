class AddLaunchMethodToTools < ActiveRecord::Migration[8.0]
  def change
    add_column :tools, :launch_method, :string, default: nil
  end
end
