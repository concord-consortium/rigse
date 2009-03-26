class CreateMultipleChoices < ActiveRecord::Migration
  def self.up
    create_table :multiple_choices do |t|
      t.timestamps
      t.string      :name
      t.text         :description
      t.integer     :user_id
      t.column      :uuid, :string, :limit => 36
      t.text        :prompt
      t.string      :options
      t.timestamps
    end
  end

  def self.down
    drop_table :multiple_choices
  end
end
