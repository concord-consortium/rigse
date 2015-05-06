class API::V1::SearchController < API::APIController

  include React::DataHelpers

  def search
    opts = params.merge(:user_id => current_visitor.id)
    opts[:include_official] = true if request.query_parameters.empty?
    begin
      search_material(opts)
      render json: search_results_data
    rescue => e
      ExceptionNotifier::Notifier.exception_notification(request.env, e).deliver
      error('Search unavailable')
    end
  end

  private

  def search_material(opts)
    @search = Search.new(opts)
  end

end
