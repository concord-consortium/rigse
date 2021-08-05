class AddIsFinalToSaveableOpenResponseAnswers < ActiveRecord::Migration[5.1]
  def change
    add_column :saveable_open_response_answers, :is_final, :boolean
  end
end
