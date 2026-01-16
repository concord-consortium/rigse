# These indexes are added to improve performance for the report server and not the runtime
class AddPortalPerformanceIndexes < ActiveRecord::Migration[8.0]
  def change
    # Improves performance when joining student_clazzes to students table in learner queries
    add_index :portal_student_clazzes, :student_id, name: 'index_portal_student_clazzes_on_student_id'

    # Composite index for EXISTS subqueries filtering runs by learner and date range
    add_index :portal_runs, [:learner_id, :start_time], name: 'index_portal_runs_on_learner_id_and_start_time'

    # Improves performance when joining permission_forms to admin_projects table
    add_index :portal_permission_forms, :project_id, name: 'index_portal_permission_forms_on_project_id'
  end
end
