module ResearcherDashboard
  # Mints the two Firebase custom tokens a researcher's Analyze Class MicroVM runs on.
  #
  # The session token travels in the VM's launch payload and names no class; it is what
  # the lifecycle hooks use to write the researcher's status document. A class token
  # additionally carries class_hash, which is what CLUE's rules and the class-scoped
  # display rules key on. Both carry researcher_dashboard_runner: CLUE's rules use it to
  # deny writes, and report-service's rules require it for result writes. Neither shape
  # is ever issued to a browser.
  #
  # One token serves one Firebase project. A custom token is signed by that project's
  # service account and cannot be exchanged in another, so an analysis that reads CLUE
  # documents in collaborative-learning and writes results in report-service needs a
  # mint per project, named by firebase_app.
  #
  # Both shapes are authorized by the same check, so a session token names a class even
  # though it does not carry one: the class is proof of standing rather than scope. The
  # portal is the only minter of these tokens, which makes this check the only gate on
  # which classes a researcher can analyze.
  class RunnerToken
    class Error < StandardError; end
    class ClassNotFound < Error; end
    class NotAuthorized < Error; end

    TTL = 3600

    def self.session_token(user:, class_hash:, firebase_app:)
      new(user: user, class_hash: class_hash, firebase_app: firebase_app).mint(scoped_to_class: false)
    end

    def self.class_token(user:, class_hash:, firebase_app:)
      new(user: user, class_hash: class_hash, firebase_app: firebase_app).mint(scoped_to_class: true)
    end

    def initialize(user:, class_hash:, firebase_app:)
      @user = user
      @class_hash = class_hash
      @firebase_app = firebase_app
    end

    def mint(scoped_to_class:)
      clazz = authorized_clazz

      sub_claims = FirebaseTokenClaims.identity(@user).merge(
        user_type: "researcher",
        researcher_dashboard_runner: true
      )
      sub_claims[:class_hash] = clazz.class_hash if scoped_to_class

      SignedJwt.create_firebase_token(
        FirebaseTokenClaims.uid(@user), @firebase_app, TTL, { claims: sub_claims }
      )
    end

    private

    def authorized_clazz
      raise ClassNotFound, "A class_hash is required for a runner token" if @class_hash.blank?

      clazz = Portal::Clazz.find_by_class_hash(@class_hash)
      raise ClassNotFound, "A class with the requested class_hash does not exist" unless clazz

      unless @user.can_be_researcher_for_clazz?(clazz)
        raise NotAuthorized, "You do not have access to the requested class_hash as a researcher"
      end

      clazz
    end
  end
end
