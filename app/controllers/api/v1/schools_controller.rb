class API::V1::SchoolsController < API::APIController

	def index
		district_id = params['district_id']
		if district_id.blank?
			error("param 'district_id' required for school list")
		else
			@schools = Portal::School.where('district_id' => district_id).select('name, id')
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
