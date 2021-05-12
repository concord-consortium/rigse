class DeleteTeacherNotes < ActiveRecord::Migration[5.1]
  def self.up
    drop_table :teacher_notes
  end

  def self.down
    create_table :teacher_notes, :force => true do |t|
      t.text        :body
      t.integer     :user_id
      t.column      :uuid, :string, :limit => 36

      t.integer     :authored_entity_id
      t.string      :authored_entity_type

      t.timestamps
    end
  end
end
