module ResearcherDashboard
  # Where the dashboard's server-to-server calls go and which Firebase projects its runner
  # tokens are minted in. Read per call rather than at boot, so the metadata endpoint works
  # in an environment that has not configured the run path, and a missing value is a 503
  # naming it rather than a failure somewhere downstream.
  module Settings
    class NotConfigured < StandardError; end

    # report-server's base URL, for the run path's catalog resolve.
    def self.report_server_url
      fetch('REPORT_SERVER_URL').chomp('/')
    end

    # report-service's researcherDashboard function, for /run-package and /derive-profile.
    # Not REPORT_SERVICE_URL, which is the shared-bearer api function feedback metadata uses.
    def self.function_url
      fetch('RESEARCHER_DASHBOARD_FUNCTION_URL').chomp('/')
    end

    # The FirebaseApp in report-service's project. Its name is the project id, which is
    # what the runner signs in to and what it looks its class token up by.
    def self.firebase_app
      fetch('RESEARCHER_DASHBOARD_FIREBASE_APP')
    end

    # The FirebaseApp in CLUE's project, for packages that declare clue_prepull.
    # TODO(RIGSE-369): remove with the CLUE mint.
    def self.clue_firebase_app
      fetch('RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP')
    end

    def self.fetch(name)
      ENV[name].presence || raise(NotConfigured, "#{name} is not set")
    end
    private_class_method :fetch
  end
end
