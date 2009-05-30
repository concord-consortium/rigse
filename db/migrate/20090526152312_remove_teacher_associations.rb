class RemoveTeacherAssociations < ActiveRecord::Migration
  def self.up
    drop_table :teacher_notes_unifying_themes
    drop_table :teacher_notes_domains
    drop_table :teacher_notes_assessment_targets
  end

  def self.down
   #basic associations:
    create_table :teacher_notes_assessment_targets, :force => true  do |t|
      t.integer     :teacher_note_id
      t.integer     :assessment_target_id
    end

    create_table :teacher_notes_domains, :force => true  do |t|
      t.integer     :teacher_note_id
      t.integer     :domain_id
    end

    create_table :teacher_notes_unifying_themes, :force => true  do |t|
      t.integer     :teacher_note_id
      t.integer     :unifying_theme_id
    end
  end
  
end