class AddUuidToSaveableMultipleChoices < ActiveRecord::Migration
  def change
    add_column :saveable_multiple_choices, :uuid, :string, :limit => 36
  end
end
