# The capabilities a scoped token can carry, in its space-separated `scope` claim. A token
# with no `scope` is a full-user credential, as every token that predates this convention
# is; one with a `scope` may be used only where an action declares one of its capabilities
# (TokenCapabilityCheck), and even there the capability is a ceiling, never a grant: the
# action still runs its own authorization.
#
# Each capability names the context type it is bound to (a token carrying it applies it
# only to the one object in its `context` claim), the service that accepts it (which is
# what puts that service in the token's `aud`), and, for a context-bound capability, the
# check the portal runs before binding a context into a token.
module TokenCapabilities
  CLASS_RESEARCHER_READ = 'class:researcher-read'.freeze
  CLASS_RESEARCHER_RUN  = 'class:researcher-run'.freeze
  PACKAGES_READ         = 'packages:read'.freeze
  PORTAL_API            = 'portal-api'.freeze

  CLASS_CONTEXT = 'class'.freeze

  class Denied < StandardError; end

  Capability = Struct.new(:name, :context_type, :audience, :gate, keyword_init: true)

  RESEARCHER_GATE = ->(user, clazz) { user.can_be_researcher_for_clazz?(clazz) }

  REGISTRY = [
    Capability.new(name: CLASS_RESEARCHER_READ, context_type: CLASS_CONTEXT, audience: :portal, gate: RESEARCHER_GATE),
    Capability.new(name: CLASS_RESEARCHER_RUN,  context_type: CLASS_CONTEXT, audience: :portal, gate: RESEARCHER_GATE),
    Capability.new(name: PACKAGES_READ,         context_type: nil,           audience: :report_server),
    Capability.new(name: PORTAL_API,            context_type: nil,           audience: :portal)
  ].index_by(&:name).freeze

  def self.names
    REGISTRY.keys
  end

  def self.known?(name)
    REGISTRY.key?(name)
  end

  def self.fetch(name)
    REGISTRY.fetch(name) { raise ArgumentError, "Unknown token capability: #{name}" }
  end

  # Splits a space-separated scope string (RFC 6749 section 3.3) into capability names.
  def self.parse(scope)
    scope.to_s.split(' ').uniq
  end

  # The context types the given capabilities are bound to, without nil.
  def self.context_types(names)
    names.map { |n| fetch(n).context_type }.compact.uniq
  end

  # The audience a capability's service is known by, or nil when it is not configured.
  # report-server is its URL and never the string 'report-server', which is its mint
  # assertion's audience, so an access token can never pass that check.
  def self.audience_value(name)
    case fetch(name).audience
    when :portal        then APP_CONFIG[:site_url]
    when :report_server then ENV['REPORT_SERVER_URL'].presence&.chomp('/')
    end
  end

  # The settings a set of capabilities needs and that this environment lacks.
  def self.missing_settings(names)
    names.select { |n| audience_value(n).nil? }.map { |n| fetch(n).audience == :report_server ? 'REPORT_SERVER_URL' : 'site_url' }.uniq
  end
end
