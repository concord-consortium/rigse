module ResearcherDashboard
  # Queues a batch of packages for one researcher on one class. It resolves every package
  # before it mints or sends anything, so a batch queues whole or not at all, and answers
  # as soon as the function has accepted the work; it never waits for a VM. The tokens go
  # only to the function, and only the queue state comes back.
  class RunPackage
    # Four upstream calls of 10 seconds each, plus the function's Firestore transactions.
    READ_TIMEOUT = 45
    UPSTREAM = Upstream::NAMES[:function]

    def self.call(user:, clazz:, packages:, launch_token:)
      new(user: user, clazz: clazz, packages: packages, launch_token: launch_token).call
    end

    def initialize(user:, clazz:, packages:, launch_token:)
      @user = user
      @clazz = clazz
      @packages = packages
      @launch_token = launch_token
    end

    def call
      # One at a time: each resolve is a portal read at report-server.
      resolved = @packages.map { |p| Catalog.resolve(**p, launch_token: @launch_token) }
      firebase_app = Settings.firebase_app
      # Minted whenever a package asks for the CLUE pre-pull, whatever the runner does with
      # it: rigse learning the runner's configuration would be the wrong coupling.
      apps = [firebase_app]
      apps << Settings.clue_firebase_app if resolved.any? { |r| r[:clue_prepull] }
      url = "#{Settings.function_url}/run-package"

      response = Upstream.post_json(:function, url, body: body(resolved, apps, firebase_app),
                                    bearer: Assertions.report_service_functions(user: @user),
                                    read_timeout: READ_TIMEOUT)
      case response.code
      when 202
        accepted = Upstream.parsed(response)
        unless accepted.is_a?(Hash) && accepted['queue'].is_a?(Array) && accepted['appended'].is_a?(Array) &&
               accepted['vm'].is_a?(String)
          raise Upstream.malformed(:function, 202, 'malformed 202 body',
                                   'report-service accepted the run but its answer was not the queue state')
        end
        accepted.slice('queue', 'appended', 'vm')
      when 409
        raise Upstream.refusal(:function, response, status: 409, message: 'report-service refused the run')
      else
        raise Upstream.refusal(:function, response, message: 'report-service refused the run')
      end
    rescue Refusal => e
      raise unless e.status == 504 && e.details&.dig(:upstream) == UPSTREAM
      # The function records the queue before it asks for a VM, so the work may be waiting.
      raise Refusal.new(504, 'report-service did not answer in time; the packages may already be queued', e.details)
    end

    private

    def body(resolved, apps, firebase_app)
      {
        packages: resolved.map { |r| r.slice(:identity, :version, :checksum, :catalog_id) },
        scope: {
          kind: 'class',
          collection: 'classes',
          id: @clazz.class_hash,
          classes: [{ class_hash: @clazz.class_hash, class_id: @clazz.id }],
          assignments: Scope.new(@clazz).run_assignments
        },
        class_tokens: apps.index_with { |app| RunnerTokens.class_token(user: @user, clazz: @clazz, firebase_app: app) },
        session_token: RunnerTokens.session_token(user: @user, firebase_app: firebase_app),
        firebase_project: firebase_app,
        # An assertion, not a token: the function exchanges it at report-server only when it
        # launches a VM, so the reuse branch leaves the running VM's token alone.
        report_server_assertion: Assertions.report_server(user: @user, clazz: @clazz)
      }
    end
  end
end
