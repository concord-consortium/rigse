class Portal::ClazzObserver < ActiveRecord::Observer
  def after_create(user)
    ClazzMailer.clazz_creation_notification(user).deliver
  end
end
