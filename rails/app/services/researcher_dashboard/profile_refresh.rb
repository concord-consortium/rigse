module ResearcherDashboard
  # Hands the class's assignment URLs to report-service's deriver. rigse answers as soon as
  # the function has queued the derivation; the app learns the result from the profile
  # document it is already listening to.
  module ProfileRefresh
    READ_TIMEOUT = 10

    def self.call(user:, clazz:)
      body = Scope.new(clazz).derive_profile_body
      response = Upstream.post_json(:function, "#{Settings.function_url}/derive-profile",
                                    body: body, bearer: Assertions.report_service_functions(user: user),
                                    read_timeout: READ_TIMEOUT)
      raise Upstream.refusal(:function, response, message: 'report-service refused the profile refresh') unless response.code == 202
      { queued: true, assignment_fingerprint: body[:assignment_fingerprint] }
    end
  end
end
