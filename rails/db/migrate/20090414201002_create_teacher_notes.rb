class CreateTeacherNotes < ActiveRecord::Migration
  def self.up
    
    #primary table
    create_table :teacher_notes, :force => true do |t|
      t.text        :body
      t.text        :author
      t.column      :uuid, :string, :limit => 36
      
      t.integer     :authored_entity_id
      t.string      :authored_entity_type
      
      t.timestamps
    end
    
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

  def self.down
    drop_table :teacher_notes_unifying_themes
    drop_table :teacher_notes_domains
    drop_table :teacher_notes_assessment_targets
    drop_table :teacher_notes
  end
end
