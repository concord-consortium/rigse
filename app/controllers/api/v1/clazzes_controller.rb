class API::V1::ClazzesController < API::APIController

  # GET api/v1/classes/:id
  def show
    class_id = params.require(:id)
    clazz = Portal::Clazz.find(class_id)
    return unauthorized unless can_show_clazz(clazz)
    render :json => clazz.to_api_json
  end

  private

  def can_show_clazz(clazz)
    return false if current_user.nil?
    # User has to be member of a class (its student or teacher).
    student = current_user.portal_student
    teacher = current_user.portal_teacher
    return clazz.students.include?(student) if student
    return clazz.teachers.include?(teacher) if teacher
    return false
  end

end
