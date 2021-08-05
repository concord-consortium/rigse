class AddUuidToSaveableMultipleChoices < ActiveRecord::Migration[5.1]
  def change
    add_column :saveable_multiple_choices, :uuid, :string, :limit => 36
  end
end
