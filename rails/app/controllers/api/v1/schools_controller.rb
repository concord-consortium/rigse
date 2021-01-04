class API::V1::SchoolsController < API::APIController

  def index
    country_id  = params['country_id']
    zipcode = params['zipcode']
    if country_id.blank? || zipcode.blank?
      return error("'country_id' and 'zipcode' are required for school list")
    else
      @schools = API::V1::SchoolRegistration.for_country_and_zipcode(country_id, zipcode)
    end
    render :json => @schools
  end

  def create
    registration = API::V1::SchoolRegistration.new(params)
    if registration.valid?
      registration.save
      render :json => registration.attributes
    else
      return error(registration.errors)
    end
  end

  private

  def can_create_new_school(params)
    Admin::Settings.default_settings.allow_adhoc_schools
  end

end
