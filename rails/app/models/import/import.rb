class Import::Import < ActiveRecord::Base
  serialize :import_data, JSON
  IMPORT_TYPE_SCHOOL_DISTRICT = 0
  IMPORT_TYPE_USER = 1
  IMPORT_TYPE_ACTIVITY = 2
  IMPORT_TYPE_BATCH_ACTIVITY = 3

  scope :in_progress, lambda{|import_type| where(job_finished_at: nil, import_type: import_type)} 

  def working?
    job_id.present?
  end

  def finished?
    job_finished_at.present?
  end

  def in_progress
    working? && !finished?
  end

  def send_mail(user)
    UserMailer.deliver_export_notification(user,self)
  end

end