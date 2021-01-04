class CreateMultipleChoices < ActiveRecord::Migration
  def self.up
    create_table :multiple_choices do |t|
      
      t.integer   "user_id"
      t.string    "uuid",        :limit => 36
      t.string    "name"
      t.text      "description"
      
      t.text :prompt

      t.timestamps
    end
  end

  def self.down
    drop_table :multiple_choices
  end
end
