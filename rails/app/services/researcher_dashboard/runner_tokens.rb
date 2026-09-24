module ResearcherDashboard
  # The Firebase custom tokens a researcher's runner signs in with. Both carry
  # researcher_dashboard_runner, which report-service's rules require for the runner's
  # writes and CLUE's rules use to deny them; neither is ever returned to a browser.
  #
  # The session token names no class. A class token carries the class_hash the
  # class-scoped rules key on, one per Firebase project, since a custom token is signed by
  # one project's service account and cannot be exchanged in another.
  #
  # The caller authorizes: nothing here checks can_be_researcher_for_clazz?.
  module RunnerTokens
    # The longest a Firebase custom token may live.
    TTL = 3600

    def self.session_token(user:, firebase_app:)
      mint(user, firebase_app, {})
    end

    def self.class_token(user:, clazz:, firebase_app:)
      mint(user, firebase_app, { class_hash: clazz.class_hash })
    end

    def self.mint(user, firebase_app, extra)
      claims = FirebaseTokenClaims.identity(user)
        .merge(user_type: 'researcher', researcher_dashboard_runner: true)
        .merge(extra)
      SignedJwt.create_firebase_token(FirebaseTokenClaims.uid(user), firebase_app, TTL, { claims: claims })
    end
    private_class_method :mint
  end
end
