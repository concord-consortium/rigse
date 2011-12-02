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

      t.index    :school_id
      t.index    :learner_id
      t.index    :offering_id
      t.index    :runnable_id
      t.index    :class_id
      t.index    :last_run
    end

  end

  def self.down
    drop_table :report_learners
  end
end
