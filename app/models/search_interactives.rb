class SearchInteractives < Search

    attr_accessor   :available_model_types
    attr_accessor   :model_types

    #
    # Create a new SeachInteractives. 
    #
    def initialize(opts={})

        #
        # Set the models to search.
        #
        self.searchable_models          = [Interactive]

        self.model_types                = opts[:model_types] || nil
        self.available_model_types      = []

        super(opts)
    end

    #
    # Set available search params for Interactives
    #
    def fetch_custom_search_params
        results = self.engine.search(self.searchable_models) do |s|
            s.facet :model_types
        end
        results.facet(:model_types).rows.each do |facet|
            self.available_model_types << facet.value
        end
    end

    #
    # Add filters for Interactives
    #
    def add_custom_search_filters(search)
        return if model_types.nil? || model_types == "All"
        search.any_of do |s|
            s.with(:model_types, model_types)
        end
    end

end
