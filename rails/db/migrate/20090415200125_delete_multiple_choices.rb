class DeleteMultipleChoices < ActiveRecord::Migration
  def self.up
    drop_table :multiple_choices
  end
  
  def self.down
    create_table :multiple_choices do |t|
      t.integer     :user_id
      t.column      :uuid, :string, :limit => 36

      t.string      :name
      t.text        :description
      t.text        :prompt
      t.string      :options

      t.timestamps
    end
  end
end
