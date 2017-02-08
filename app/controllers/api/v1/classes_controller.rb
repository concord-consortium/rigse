class API::V1::ClassesController < API::APIController

  # GET api/v1/classes/:id
  def show
    if current_visitor.anonymous?
      return error('You must be logged in to use this endpoint')
    end

    if !current_visitor.portal_student && !current_visitor.portal_teacher
      error('You must be logged in as a student to use this endpoint')
    end

    clazz = Portal::Clazz.find_by_id(params[:id])
    if !clazz
      return error('The requested class was not found')
    end

    student_in_class = current_visitor.portal_student && current_visitor.portal_student.has_clazz?(clazz)
    teacher_in_class = !student_in_class || (current_visitor.portal_teacher && current_visitor.portal_teacher.has_clazz?(clazz))

    if (!student_in_class && !teacher_in_class)
      return error('You are not a student or teacher of the requested class')
    end

    render_info clazz
  end

  # GET api/v1/classes/info?class_word=[class word]
  def info
    class_word = params.require(:class_word)
    clazz = Portal::Clazz.find_by_class_word(class_word)
    if !clazz
      return error('The requested class was not found')
    end

    render_info clazz
  end

  private

  def render_info(clazz)
    state = nil
    if school = clazz.school
      state = school.state
    end

    render :json => {
      :uri => url_for(clazz),
      :name => clazz.name,
      :state => state,
      :class_hash => clazz.class_hash,
      :teachers => clazz.teachers.includes(:user).map{|teacher|
        {
          :id => url_for(teacher.user),
          :first_name => teacher.user.first_name,
          :last_name => teacher.user.last_name
        }
      },
      :students => clazz.students.includes(:user).map {|student|
        {
          :id => url_for(student.user),
          :email => student.user.email,
          :first_name => student.user.first_name,
          :last_name => student.user.last_name
        }
      }
    }
  end

end
