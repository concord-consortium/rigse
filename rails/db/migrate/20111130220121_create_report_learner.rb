class CreateReportLearner < ActiveRecord::Migration
  def self.up
    # this is de-normalized table, with some indexes
    # to speed up reporting. It will help with data filtering.
    create_table :report_learners do |t|
      t.integer  :learner_id
      t.integer  :student_id
      t.integer  :user_id 
      t.integer  :offering_id
      t.integer  :class_id

      t.datetime :last_run
      t.datetime :last_report

      t.string   :offering_name
      t.string   :teachers_name
      t.string   :student_name
      t.string   :username
      
      t.string   :school_name 
      t.string   :class_name

      t.integer  :runnable_id
      t.integer  :runnable_name

      t.integer  :school_id

      t.integer  :num_answerables
      t.integer  :num_answered
      t.integer  :num_correct
    end

    add_index :report_learners, :school_id
    add_index :report_learners, :learner_id
    add_index :report_learners, :offering_id
    add_index :report_learners, :runnable_id
    add_index :report_learners, :class_id
    add_index :report_learners, :last_run
  end

  def self.down
    remove_index :report_learners, :school_id
    remove_index :report_learners, :learner_id
    remove_index :report_learners, :offering_id
    remove_index :report_learners, :runnable_id
    remove_index :report_learners, :class_id
    remove_index :report_learners, :last_run

    drop_table :report_learners
  end
end
