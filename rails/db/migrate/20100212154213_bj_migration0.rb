class BjMigration0 < ActiveRecord::Migration

  def self.up
    create_table :bj_config, :primary_key => "bj_config_id", :force => true do |t|
      t.text :hostname
      t.text :key
      t.text :value
      t.text :cast
    end

    create_table :bj_job, :primary_key => "bj_job_id", :force => true do |t|
      t.text     :command
      t.text     :state
      t.integer  :priority
      t.text     :tag
      t.integer  :is_restartable
      t.text     :submitter
      t.text     :runner
      t.integer  :pid
      t.datetime :submitted_at
      t.datetime :started_at
      t.datetime :finished_at
      t.text     :env
      t.text     :stdin
      t.text     :stdout
      t.text     :stderr
      t.integer  :exit_status
    end

    create_table :bj_job_archive, :primary_key => "bj_job_archive_id", :force => true do |t|
      t.text     :command
      t.text     :state
      t.integer  :priority
      t.text     :tag
      t.integer  :is_restartable
      t.text     :submitter
      t.text     :runner
      t.integer  :pid
      t.datetime :submitted_at
      t.datetime :started_at
      t.datetime :finished_at
      t.datetime :archived_at
      t.text     :env
      t.text     :stdin
      t.text     :stdout
      t.text     :stderr
      t.integer  :exit_status
    end
  end

  def self.down
    drop_table :bj_config
    drop_table :bj_job
    drop_table :bj_job_archive
  end

end
