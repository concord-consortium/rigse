module RestrictedTeacherController

  #
  # Checks if the current user is a teacher and the class
  # specified by params[:id] belongs to this teacher.
  # Raises Pundit::NotAuthorizedError if the check fails.
  #
  def check_teacher_owns_clazz

    # logger.info("INFO check_teacher_owns_clazz #{params}")

    teacher_clazz_id = params[:clazz_id]
    if teacher_clazz_id.nil?
      teacher_clazz_id = params[:id]
    end

    if teacher_clazz_id.nil?
      # logger.info("INFO cannot find class id in #{params}")
      raise Pundit::NotAuthorizedError
    end

    teacher_clazz_id = teacher_clazz_id.to_i

    unless current_visitor.portal_teacher
      # logger.info("INFO check_teacher_owns_clazz not a teacher.")
      raise Pundit::NotAuthorizedError
    end

    current_visitor.portal_teacher.teacher_clazzes.each do |teacher_clazz|
      if teacher_clazz.clazz_id == teacher_clazz_id

        # logger.info("INFO check_teacher_owns_clazz authorized.")
        return
      end
    end

    # logger.info("INFO check_teacher_owns_clazz not authorized.")
    raise Pundit::NotAuthorizedError

  end

end
