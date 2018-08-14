class Portal::ClazzMailer < Devise::Mailer
  default :from => "#{APP_CONFIG[:site_name]} <#{APP_CONFIG[:help_email]}>"

  def clazz_creation_notification(user, clazz)
    user.cohorts.each do |uc|
      if uc.email_notifications_enabled
        @cohort = uc
        @cohort_project = Admin::Project.find(@cohort.project_id)
        @cohort_name = @cohort.name
        cohort_admins = @cohort_project.project_admins
        @clazz_name = clazz.name
        @user = user
        subject = "#{@cohort_project.name} cohort #{@cohort_name} Update: New class created by #{@user.name}"
        finish_email(cohort_admins, subject)
      end
    end
  end

  def clazz_assignment_notification(user, clazz, offering_name)
    user.cohorts.each do |uc|
      if uc.email_notifications_enabled
        @cohort = uc
        @cohort_project = Admin::Project.find(@cohort.project_id)
        @cohort_name = @cohort.name
        cohort_admins = @cohort_project.project_admins
        @clazz_name = clazz.name
        @offering_name = offering_name
        @user = user
        subject = "#{@cohort_project.name} cohort #{@cohort_name} Update: New assignment added by #{@user.name}"
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
