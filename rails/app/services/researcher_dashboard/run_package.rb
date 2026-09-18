module ResearcherDashboard
  # Starts one package run against one class: authorizes once, mints every credential the
  # run needs, and hands them to report-service, which decides whether a MicroVM has to be
  # launched and asks that VM to do the work.
  #
  # The portal mints and never launches. It holds the Firebase signing keys and the class
  # check; report-service holds the AWS credentials. Keeping the split is what stops the
  # one gate on which classes a researcher may analyze becoming a copyable key.
  #
  # Which Firebase projects a run signs into is the caller's to name, the way
  # API::V1::JwtController#firebase already takes firebase_app from whoever calls it.
  # Naming a project grants nothing on its own: every mint below passes the same class
  # check first.
  #
  # The runner tokens are handed to report-service directly and never returned to the
  # caller, so a browser can ask for a run without ever holding a credential that carries
  # the runner claim.
  class RunPackage
    class Error < StandardError; end
    class NotConfigured < Error; end
    class Refused < Error; end

    def self.call(user:, clazz:, package:, firebase_project:, firebase_apps:)
      new(user: user, clazz: clazz, package: package,
          firebase_project: firebase_project, firebase_apps: firebase_apps).call
    end

    def initialize(user:, clazz:, package:, firebase_project:, firebase_apps:)
      @user = user
      @clazz = clazz
      @package = package
      @firebase_project = firebase_project
      @firebase_apps = firebase_apps
    end

    def call
      raise NotConfigured, "REPORT_SERVICE_URL is not set" if base_url.blank?
      raise NotConfigured, "REPORT_SERVICE_BEARER_TOKEN is not set" if bearer.blank?

      response = HTTParty.post(
        "#{base_url.chomp('/')}/run_package",
        headers: {
          "Authorization" => "Bearer #{bearer}",
          "Content-Type" => "application/json"
        },
        body: body.to_json,
        timeout: 30
      )

      unless response.success?
        raise Refused, "report-service refused the package run: #{response.code}"
      end

      response.parsed_response
    end

    private

    def body
      {
        scope: { kind: "class", class_hash: @clazz.class_hash },
        package: @package,
        class_tokens: class_tokens,
        # The researcher's status document lives only in the project report-service runs
        # in, so the token that writes it is minted for that project alone.
        session_token: RunnerToken.session_token(
          user: @user, class_hash: @clazz.class_hash, firebase_app: @firebase_project
        ),
        # Exchanged at report-server for the researcher's own API token, and only on the
        # branch that creates a VM, since minting revokes their previous one.
        report_server_assertion: ReportServerAssertion.mint(user: @user),
        firebase_project: @firebase_project,
        platform_id: APP_CONFIG[:site_url],
        platform_user_id: @user.id,
        portal: portal_segment
      }
    end

    # One token per Firebase project the run signs into, keyed by the name of the
    # firebase_apps row that signed it. A custom token is signed by one project's service
    # account and cannot be exchanged in another, so a run reading CLUE documents and
    # writing report-service results needs one of each.
    def class_tokens
      @firebase_apps.each_with_object({}) do |app, tokens|
        tokens[app] = RunnerToken.class_token(
          user: @user, class_hash: @clazz.class_hash, firebase_app: app
        )
      end
    end

    # The Firestore path segment: the portal host with dots replaced by underscores,
    # matching the convention CLUE and report-service already use for portal-keyed
    # collections. Hostnames cannot contain underscores, so the two forms round-trip.
    def portal_segment
      URI.parse(APP_CONFIG[:site_url]).host.tr(".", "_")
    end

    def base_url
      ENV['REPORT_SERVICE_URL']
    end

    def bearer
      ENV['REPORT_SERVICE_BEARER_TOKEN']
    end
  end
end
