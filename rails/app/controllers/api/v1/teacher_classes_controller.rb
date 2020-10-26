class API::V1::TeacherClassesController < API::APIController

  def show
    auth = auth_teacher(params)
    return error(auth[:error]) if auth[:error]
    user = auth[:user]

    class_ownership = verify_teacher_class_ownership(user, params)
    return error(class_ownership[:error]) if class_ownership[:error]
    teacher_clazz = class_ownership[:teacher_clazz]

    render_teacher_clazz(teacher_clazz)
  end

  def sort
    auth = auth_teacher(params)
    return error(auth[:error]) if auth[:error]
    user = auth[:user]

    ids = params[:ids]
    if !ids
      return error('Missing ids parameter')
    end

    # NOTE: we can't use Portal::TeacherClazz.find(ids) here as the returned array is not in the order of the passed ids
    # and we need the order preserved so we can update the position based on the id order
    ids.each do |id|
      begin
        teacher_clazz = Portal::TeacherClazz.find(id)
      rescue ActiveRecord::RecordNotFound => e
        return error("Invalid teacher class id: #{id}") if !teacher_clazz
      end
      return error("You are not a teacher of class: #{id}") if !teacher_clazz.clazz.is_teacher?(user)
    end

    ids.each_with_index do |id,idx|
      Portal::TeacherClazz.update(id, :position => (idx + 1))
    end

    render_ok
  end

  def set_active
    auth = auth_teacher(params)
    return error(auth[:error]) if auth[:error]
    user = auth[:user]

    class_ownership = verify_teacher_class_ownership(user, params)
    return error(class_ownership[:error]) if class_ownership[:error]
    teacher_clazz = class_ownership[:teacher_clazz]

    teacher_clazz.active = !!params[:active]
    teacher_clazz.save!

    render_ok
  end

  def copy
    auth = auth_teacher(params)
    return error(auth[:error]) if auth[:error]
    user = auth[:user]

    class_ownership = verify_teacher_class_ownership(user, params)
    return error(class_ownership[:error]) if class_ownership[:error]
    teacher_clazz = class_ownership[:teacher_clazz]

    class_to_copy = teacher_clazz.clazz
    new_clazz = Portal::Clazz.new( # strong params not required
      :name => params[:name],
      :class_word => params[:classWord],
      :description => params[:description],
      :grades => class_to_copy.grades,
      :teacher => user.portal_teacher,
      :course => class_to_copy.course
    )

    class_to_copy.teachers.each do |other_teacher|
      new_clazz.add_teacher(other_teacher)
    end
    return error(new_clazz.errors.full_messages.join(" and ")) if !new_clazz.save

    class_to_copy.offerings.each do |offering|
      new_offering = Portal::Offering.where(clazz_id: new_clazz.id, runnable_type: offering.runnable_type, runnable_id: offering.runnable_id).first_or_create
      new_offering.status = offering.status
      new_offering.active = offering.active
      new_offering.save!
    end

    new_teacher_clazz = Portal::TeacherClazz.where(teacher_id: user.portal_teacher.id, clazz_id: new_clazz.id).first

    render_teacher_clazz(new_teacher_clazz)
  end

  private

  def render_ok
    render :json => { success: true }, :status => :ok
  end

  def render_teacher_clazz(teacher_clazz)
    render :json => {
      success: true,
      data: {
        id: teacher_clazz.id,
        name: teacher_clazz.name,
        class_word: teacher_clazz.clazz.class_word,
        description: teacher_clazz.clazz.description,
        position: teacher_clazz.position
      }
    }, :status => :ok
  end

  def verify_teacher_class_ownership(user, params)
    teacher_clazz = Portal::TeacherClazz.find_by_id(params[:id])
    if !teacher_clazz
      return {error: 'The requested teacher class was not found'}
    end

    if !teacher_clazz.clazz.is_teacher?(user)
      return {error: 'You are not a teacher of the requested class'}
    end

    return {teacher_clazz: teacher_clazz}
  end

  def render_info(teacher_clazz)
    state = nil
    if school = clazz.school
      state = school.state
    end

    render :json => {
      :id => clazz.id,
      :uri => api_v1_class_url(clazz.id),
      :name => clazz.name,
      :state => state,
      :class_hash => clazz.class_hash,
      :class_word => clazz.class_word,
      :edit_path => edit_portal_clazz_path(clazz),
      :assign_materials_path => configured_search_path,
      :teachers => clazz.teachers.includes(:user).map { |teacher|
        {
          :id => url_for(teacher.user),
          :user_id => teacher.user.id,
          :first_name => teacher.user.first_name,
          :last_name => teacher.user.last_name
        }
      },
      :students => clazz.students.includes(:user).map { |student|
        {
          :id => url_for(student.user),
          :user_id => student.user.id,
          :email => student.user.email,
          :first_name => student.user.first_name,
          :last_name => student.user.last_name
        }
      },
      :offerings => clazz.teacher_visible_offerings.map { |offering|
        {
          :id => offering.id,
          :name => offering.name,
          :active => offering.active,
          :locked => offering.locked,
          :url => api_v1_offering_url(offering.id)
        }
      },
      :external_class_reports => clazz.external_class_reports.map { |external_report|
        {
            :id => external_report.id,
            :name => external_report.name,
            :launch_text => external_report.launch_text,
            :url => portal_external_class_report_url(clazz, external_report)
        }
      },
    }
  end

  def portal_clazz_strong_params(params)
    params && params.permit(:class_hash, :class_word, :course_id, :default_class, :description, :end_time, :logging, :name,
                            :section, :semester_id, :start_time, :status, :teacher_id, :uuid)
  end
end
