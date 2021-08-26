class API::V1::SearchController < API::APIController
  include Materials::DataHelpers

  def search
    opts = params.merge(:user_id => current_visitor.id)
    begin
      @search = Search.new(opts)
      # Return query string, so the response can be identified by the client code.
      render json: {query: request.query_string, filters: search_filters_data, results: search_results_data}
    rescue => e
      ExceptionNotifier::Notifier.exception_notification(request.env, e).deliver
      return error('Search unavailable')
    end
  end

  def search_suggestions
    search_term = params[:search_term]
    if search_term == nil
      return error('Missing search_term parameter')
    end

    # nil.to_i and "foo".to_i return 0
    num_results = params[:num_results].to_i
    num_results = 10 if num_results == 0

    other_params = {
      :without_teacher_only => current_visitor.anonymous?,
      :sort_order => Search::Score,
      :user_id => current_visitor.id
    }
    search = Search.new(params.merge(other_params))
    suggestions = search.results[:all].slice(0, num_results)
    render json: {success: true, search_term: search_term, suggestions: suggestions.map { |s| s.name }}
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

    skip_lightbox_reloads = (params[:skip_lightbox_reloads] == true.to_s)

    {
      type: type.to_s.pluralize,
      header: view_context.t(type).pluralize.titleize,
      materials: materials_data(collection, nil, params[:include_related].to_i || 0, skip_lightbox_reloads),
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

  def search_filters_data
    filters = {}
    filters[:number_authored_resources] = @search.number_authored_resources
    filters
  end


end
