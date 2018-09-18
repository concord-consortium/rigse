module API::V1::PunditSupport

  def failed_to_log_in
    raise Pundit::NotAuthorizedError, 'You must be logged in to use this endpoint'
  end

  def is_admin?
    user && user.is_admin?
  end
end
