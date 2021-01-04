class RenameAuthorNoteAuthorandTeacherNotAuthor < ActiveRecord::Migration
  def self.up
    add_column :teacher_notes, :user_id, :integer
    add_column :author_notes,  :user_id, :integer
    remove_column :teacher_notes, :author
    remove_column :author_notes, :author
  end

  def self.down
    remove_column :teacher_notes, :user_id
    remove_column :author_notes, :user_id
    add_column :teacher_notes, :author, :text
    add_column :author_notes,  :author, :text
  end
end
