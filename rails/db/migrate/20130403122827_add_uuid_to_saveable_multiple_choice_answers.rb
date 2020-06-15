class AddUuidToSaveableMultipleChoiceAnswers < ActiveRecord::Migration
  def change
    add_column :saveable_multiple_choice_answers, :uuid, :string, :limit => 36
  end
end
