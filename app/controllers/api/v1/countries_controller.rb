class API::V1::CountriesController < API::APIController

  def index
    @countries = Portal::Country.all.sort_by{ |k| k["name"]}.map{ |c| {name: c.name, id: c.id} }
    render :json => @countries
  end

end
