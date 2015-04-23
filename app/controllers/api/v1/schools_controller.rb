class API::V1::SchoolsController < API::APIController

	def index
		district_id = params['district_id']
		country_id  = params['country_id']
		if district_id.blank? && country_id.blank?
			error("param 'district_id' or 'country_id' are required for school list")
		elsif district_id
			@schools = API::V1::SchoolRegistration.for_district(district_id)
		else
			@schools = API::V1::SchoolRegistration.for_country(country_id)
		end
		render :json => @schools
	end

  def create
    registration = API::V1::SchoolRegistration.new(params)
    if registration.valid?
      registration.save
      render :json => registration.attributes
    else
      error(registration.errors)
    end
  end

  private

  def can_create_new_school(params)
    Admin::Settings.default_settings.allow_adhoc_schools
  end
  
end
