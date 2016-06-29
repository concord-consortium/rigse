class AddTeacherInfoToReportLearner < ActiveRecord::Migration
  def up
    add_column :report_learners, :teachers_district, :string
    add_column :report_learners, :teachers_state,    :string
    add_column :report_learners, :teachers_email,    :string

    Report::Learner.find_each(batch_size: 100) do |rl|
      rl.update_teacher_info_fields
      rl.save!
    end
  end

  def down
    remove_column :report_learners, :teachers_district
    remove_column :report_learners, :teachers_state
    remove_column :report_learners, :teachers_email
  end
end
