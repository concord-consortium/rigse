class Portal::ClazzMailer < ActionMailer::Base
  default :from => "#{APP_CONFIG[:site_name]} <#{APP_CONFIG[:help_email]}>"
  helper :theme
  def clazz_creation_notification(user, clazz)
    if user.present? && user.portal_teacher.present?
      @teacher_name = user.name
      @clazz_name = clazz.name
      subject = "Portal Update: New class created by #{@teacher_name}"
      email_cohort_admins(user.portal_teacher, subject)
    end
  end

  def clazz_assignment_notification(user, clazz, offering_name)
    if user.present? && user.portal_teacher.present?
      @teacher_name = user.name
      @clazz_name = clazz.name
      @offering_name = offering_name
      subject = "Portal Update: New assignment added by #{@teacher_name}"
      email_cohort_admins(user.portal_teacher, subject)
    end
  end

  protected

  def cohort_admin_emails_to_notify(user)
    cohorts = user.cohorts.
      where(email_notifications_enabled: true).
      where('project_id is not null')

    cohort_admins = []
    cohorts.each do |cohort|
      cohort_project = cohort.project
      cohort_admins += cohort_project.project_admins
    end

    non_nil_admins = cohort_admins.reject(&:nil?)
    non_nil_admins.map do |cohort_admin|
      "#{cohort_admin.name} <#{cohort_admin.email}>"
    end
  end

  def email_cohort_admins(user, subject)
    emails = cohort_admin_emails_to_notify(user)
    if emails.any?
      mail(:to => emails,
           :subject => subject,
           :date => Time.now)
    end
  end

end
