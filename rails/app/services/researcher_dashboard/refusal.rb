module ResearcherDashboard
  # A refusal with the status and message the app should see. Services raise it and the
  # controller renders it through API::APIController#error, so every dashboard failure,
  # rigse's own or one passed through from report-server or the function, has one shape.
  class Refusal < StandardError
    attr_reader :status, :details

    def initialize(status, message, details = nil)
      super(message)
      @status = status
      @details = details
    end
  end
end
