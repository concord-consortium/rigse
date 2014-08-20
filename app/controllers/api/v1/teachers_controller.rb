class API::V1::TeachersController < API::APIController

  # Note that two scenarios are possible:
  # - 'school_id' is provided - school is expected to exist
  # - 'school_name' and 'district_id' are provided instead - school may be created in case of need
	def create
    if can_create_new_school(params)
      school = get_or_register_school(params[:school_name], params[:district_id])
      return unless school
      params[:school_id] = school.id
    end

    teacher_registration = API::V1::TeacherRegistration.new(params)
		if teacher_registration.valid?
			teacher_registration.save
			render :json => teacher_registration.attributes
    else
      error(teacher_registration.errors)
		end
	end

  private

  def can_create_new_school(params)
    Admin::Project.default_project.allow_adhoc_schools &&
    params[:school_id].blank? && params.has_key?(:school_name) && params.has_key?(:district_id)
  end

  def get_or_register_school(school_name, district_id)
    school = Portal::School.where(name: school_name, district_id: district_id).first
    return school if school

    # No school available, try to add new one.
    school_registration = API::V1::SchoolRegistration.new(school_name: school_name, district_id: district_id)
    if school_registration.valid?
      school_registration.save
      return school_registration.school
    else
      error(school_registration.errors)
      return nil
    end
  end

end