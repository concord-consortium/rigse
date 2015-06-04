class Export < ActiveRecord::Base
  
  EXPORT_TYPE_SCHOOL_DISTRICT = 0
  EXPORT_TYPE_USER = 1
  
  def working?
    job_id.present?
  end

  def finished?
    job_finished_at.present?
  end

  def send_mail(user)
    UserMailer.deliver_export_notification(user,self)
  end

end