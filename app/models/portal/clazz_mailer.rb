class Portal::ClazzMailer < Devise::Mailer
  default :from => "#{APP_CONFIG[:site_name]} <#{APP_CONFIG[:help_email]}>"

  def clazz_creation_notification(user)
    cohort_project_id = user.cohorts.first.project_id
    cohort_admins = Admin::Project.get_project_admins(cohort_project_id)

    subject = "New class created by #{user.name} in #{user.cohorts.first.name}"
    finish_email(cohort_admins, subject)
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
