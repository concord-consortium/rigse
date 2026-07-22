class ForwardedFirebaseToken
  class Invalid < StandardError
    attr_reader :reason
    def initialize(reason)
      @reason = reason
      super(reason.to_s)
    end
  end

  Result = Struct.new(:user, :origin_offering, :origin_clazz, keyword_init: true)

  DEFAULT_APP_NAMES = %w[report-service-pro report-service-dev].freeze

  def self.allowed_app_names
    Array(APP_CONFIG[:forwarded_firebase_app_names]).presence || DEFAULT_APP_NAMES
  end

  def self.verify(token)
    new(token).verify
  end

  def initialize(token)
    @token = token
  end

  def verify
    decoded = decode!
    app = decoded[:app]
    raise Invalid.new(:app_not_allowed) unless self.class.allowed_app_names.include?(app.name)

    claims = decoded[:data]['claims'] || {}
    raise Invalid.new(:platform_id) unless claims['platform_id'] == APP_CONFIG[:site_url]
    raise Invalid.new(:not_learner) unless claims['user_type'] == 'learner'

    user = User.find_by(id: claims['platform_user_id'])
    raise Invalid.new(:user_unresolved) unless user && user.portal_student

    offering = Portal::Offering.find_by(id: claims['offering_id'])
    raise Invalid.new(:offering_unresolved) unless offering
    clazz = offering.clazz
    raise Invalid.new(:clazz_unresolved) unless clazz
    raise Invalid.new(:class_hash_mismatch) unless clazz.class_hash == claims['class_hash']

    Result.new(user: user, origin_offering: offering, origin_clazz: clazz)
  end

  private

  def decode!
    SignedJwt.decode_firebase_token_by_iss(@token)
  rescue SignedJwt::Error => e
    # All decode failures fail closed as forwarded_token_invalid (401); the reason
    # symbol only drives the observability log line, so keep it specific rather
    # than collapsing every non-expiry failure into :signature.
    raise Invalid.new(decode_failure_reason(e.message))
  end

  def decode_failure_reason(message)
    case message
    when /expired/i        then :expired
    when /has no iss/i     then :no_iss
    when /No FirebaseApp/i then :app_not_found
    when /Undecodable/i    then :undecodable
    else :signature
    end
  end
end
