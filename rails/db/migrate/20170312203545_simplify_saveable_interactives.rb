class SimplifySaveableInteractives < ActiveRecord::Migration
  def up
    add_column :saveable_interactives, :iframe_id, :integer
    remove_column :saveable_interactives, :embeddable_id
    remove_column :saveable_interactives, :embeddable_type
  end

  def down
    remove_column :saveable_interactives, :iframe_id, :integer
    add_column :saveable_interactives, :embeddable_id, :integer
    add_column :saveable_interactives, :embeddable_type, :string
  end
end
