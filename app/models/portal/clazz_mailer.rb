class Portal::ClazzMailer < Devise::Mailer
  default :from => "#{APP_CONFIG[:site_name]} <#{APP_CONFIG[:help_email]}>"

  def clazz_creation_notification(user, clazz)
    if user.present?
      cohort_admin_emails = []
      user.cohorts.each do |uc|
        if uc.email_notifications_enabled
          @cohort = uc
          @cohort_project = Admin::Project.find(@cohort.project_id)
          @cohort_name = @cohort.name
          cohort_admins = @cohort_project.project_admins
          @clazz_name = clazz.name
          @teacher_name = user.name
          @subject = "Portal Update: New class created by #{@teacher_name}"
          cohort_admins.each do |cohort_admin|
            cohort_admin_emails.push("#{cohort_admin.name} <#{cohort_admin.email}>")
          end
        end
      end
      if cohort_admin_emails.any?
        finish_email(cohort_admin_emails, @subject, @teacher_name)
      end
    end
  end

  def clazz_assignment_notification(user, clazz, offering_name)
    if user.present?
      cohort_admin_emails = []
      user.cohorts.each do |uc|
        if uc.email_notifications_enabled
          @cohort = uc
          @cohort_project = Admin::Project.find(@cohort.project_id)
          @cohort_name = @cohort.name
          cohort_admins = @cohort_project.project_admins
          @clazz_name = clazz.name
          @offering_name = offering_name
          @teacher_name = user.name
          @subject = "Portal Update: New assignment added by #{@teacher_name}"
          cohort_admins.each do |cohort_admin|
            cohort_admin_emails.push("#{cohort_admin.name} <#{cohort_admin.email}>")
          end
        end
      end
      if cohort_admin_emails.any?
        finish_email(cohort_admin_emails, @subject, @teacher_name)
      end
    end
  end

  protected

  def finish_email(cohort_admin_emails, subject, teacher_name)
    # Need to set the theme because normally it gets set in a controller before_filter...
    set_theme(APP_CONFIG[:theme]||'default')
    mail(:to => cohort_admin_emails,
         :subject => subject,
         :date => Time.now)
  end
end
