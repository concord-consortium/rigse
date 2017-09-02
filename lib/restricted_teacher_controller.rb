module RestrictedTeacherController

  #
  # Checks if the current user is a teacher and the class
  # specified by params[:clazz_id] or params[:id] belongs to this teacher.
  # Raises Pundit::NotAuthorizedError if the check fails.
  #
  def check_teacher_owns_clazz
    # logger.info("INFO check_teacher_owns_clazz user #{current_visitor.login} params #{params}")

    clazz_id = params[:clazz_id]
    if clazz_id.nil?
      clazz_id = params[:id]
    end

    if clazz_id.nil?
      # logger.info("INFO cannot find class id in #{params}")
      raise Pundit::NotAuthorizedError
    end

    clazz_id = clazz_id.to_i

    check_teacher_owns_clazz_id(clazz_id)

  end

  #
  # Check if the clazz_id belongs to the current_visitor.
  # Raises Pundit::NotAuthorizedError if the check fails.
  #
  def check_teacher_owns_clazz_id(clazz_id)

    # logger.info("INFO check_teacher_owns_clazz_id user #{current_visitor.login} clazz_id #{clazz_id}")

    unless current_visitor.portal_teacher
      # logger.info("INFO check_teacher_owns_clazz not a teacher.")
      raise Pundit::NotAuthorizedError
    end

    current_visitor.portal_teacher.teacher_clazzes.each do |teacher_clazz|
      if teacher_clazz.clazz_id == clazz_id

        # logger.info("INFO check_teacher_owns_clazz_id authorized.")
        return
      end
    end

    # logger.info("INFO check_teacher_owns_clazz_id not authorized.")
    raise Pundit::NotAuthorizedError

  end

end
