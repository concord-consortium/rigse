class API::V1::SchoolsController < API::APIController

	def index
		district_id = params['district_id']
		country_id  = params['country_id']
		if district_id.blank? && country_id.blank?
			error("param 'district_id' or 'country_id' are required for school list")
		elsif country_id.blank?
			@schools = Portal::School.where('district_id' => district_id).select('name, id')
			render :json => @schools
		else
			@schools = Portal::School.where('country_id' => country_id).select('name, id')
			render :json => @schools
		end
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

end
