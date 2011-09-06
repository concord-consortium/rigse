class UserObserver < ActiveRecord::Observer
  def after_create(user)
    return if user.skip_notifications
    user.reload
    UserMailer.signup_notification.deliver(user)
  end

  def after_save(user)
    return if user.skip_notifications
    user.reload
    # Frieda had a good point: Why send this acitivation email?
    # It doesn't contain any useful information.   
    # UserMailer.deliver_activation(user) if user.recently_activated?
  end
end
