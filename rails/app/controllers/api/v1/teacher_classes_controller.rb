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
        clazz = Portal::Clazz.find(id)
      rescue ActiveRecord::RecordNotFound => e
        return error("Invalid class id: #{id}")
      end
      return error("You are not a teacher of class: #{id}") if !clazz.is_teacher?(user)
    end

    ids.each_with_index do |id,idx|
      teacher_clazz = Portal::TeacherClazz.where(:clazz_id => id, :teacher_id => user.portal_teacher.id).first
      return error("TeacherClazz not found") if !teacher_clazz
      teacher_clazz.update(:position => idx + 1)
    end

    render_ok
  end

  def copy
    auth = auth_teacher(params)
    return error(auth[:error]) if auth[:error]
    user = auth[:user]

    class_ownership = verify_class_ownership(user, params)
    return error(class_ownership[:error]) if class_ownership[:error]
    class_to_copy = class_ownership[:clazz]

    new_clazz = Portal::Clazz.new(
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
    if !new_clazz.save
      error_messages = new_clazz.errors.map { |options| options.message }.join(", ")
      return error(error_messages)
    end


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

  def verify_class_ownership(user, params)
    clazz = Portal::Clazz.find(params[:id])
    if !clazz
      return {error: 'The requested class was not found'}
    end

    if !clazz.is_teacher?(user)
      return {error: 'You are not a teacher of the requested class'}
    end

    return {clazz: clazz}
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
end
