class AddTeacherLearnerToPortalTeachersAndStudents < ActiveRecord::Migration[8.0]
  def change
    # The teacher's own learner account (a Portal::Student), created on first use of learner mode.
    add_column :portal_teachers, :teacher_learner_id, :integer
    add_index :portal_teachers, :teacher_learner_id, unique: true

    # True for a learner account that belongs to a teacher. Reports read this to tell
    # teacher learner activity apart from real student activity.
    add_column :portal_students, :is_teacher_learner, :boolean, default: false, null: false
  end
end
