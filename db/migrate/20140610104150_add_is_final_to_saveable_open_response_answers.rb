class AddIsFinalToSaveableOpenResponseAnswers < ActiveRecord::Migration
  def change
    add_column :saveable_open_response_answers, :is_final, :boolean
  end
end
