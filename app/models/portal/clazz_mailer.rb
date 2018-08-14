class Portal::ClazzMailer < Devise::Mailer
  default :from => "#{APP_CONFIG[:site_name]} <#{APP_CONFIG[:help_email]}>"

  def clazz_creation_notification(user)
    user.cohorts.each do |uc|
      if uc.email_notifications_enabled
        cohort_admins = Admin::Project.find(uc.project_id).project_admins
        subject = "New class created by #{user.name} in #{uc.name}"
        finish_email(cohort_admins, subject)
      end
    end
  end

  protected

  def finish_email(cohort_admins, subject)
    # Need to set the theme because normally it gets set in a controller before_filter...
    set_theme(APP_CONFIG[:theme]||'default')
    cohort_admins.each do |cohort_admin|
      mail(:to => "#{cohort_admin.name} <#{cohort_admin.email}>",
           :subject => subject,
           :date => Time.now)
    end
  end
end
