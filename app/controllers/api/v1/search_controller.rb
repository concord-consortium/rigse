class API::V1::SearchController < API::APIController
  include Materials::DataHelpers

  def search
    opts = params.merge(:user_id => current_visitor.id)
    begin
      @search = Search.new(opts)
      # Return query string, so the response can be identified by the client code.
      render json: {query: request.query_string, results: search_results_data}
    rescue => e
      ExceptionNotifier::Notifier.exception_notification(request.env, e).deliver
      error('Search unavailable')
    end
  end

  private

  def search_results_data
    results = []
    @search.results.each do |type, values|
      next if type == :all
      results.push group_data(type.downcase, values)
    end
    results
  end

  def group_data(type, collection)
    {
      type: type.to_s.pluralize,
      header: view_context.t(type).pluralize.titleize,
      materials: materials_data(collection),
      pagination: {
        current_page: collection.current_page,
        total_pages: collection.total_pages,
        start_item: collection.offset + 1,
        end_item: collection.offset + collection.length,
        total_items: collection.total_entries,
        per_page: collection.per_page
      }
    }
  end
end
