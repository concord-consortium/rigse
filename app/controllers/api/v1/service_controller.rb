require 'rake'

class API::V1::ServiceController < API::APIController

    #
    # Require clients to pass a service API key to perform
    # service actions.
    #
    before_filter :check_api_key

    def sunspot_reindex
        Rake::Task.clear
        RailsPortal::Application.load_tasks
        Rake::Task['sunspot:reindex'].invoke
        render  json: {message: "Sunspot re-index completed."},
                status: 200
    end

    private

    def check_api_key

        @server_key = ENV["SERVICE_API_KEY"]
        if ! @server_key
            return error "No Service API Key configured on server."
        end
        @client_key = params[:service_api_key]

        begin
            if @server_key != @client_key
                render  json: {message: "Invalid API key #{:service_api_key}='#{@client_key}'"},
                        status: 403
            end
        rescue Exception => e
            error(e.message, 500)
        end
    end

end
