# Limits a scoped token to the actions that declare one of its capabilities. A controller
# declares what its actions accept with accepts_token_capability; an action that declares
# nothing refuses every scoped token, and an unscoped credential is never affected.
#
# The check reads the bearer itself rather than asking Warden, so it runs on actions that
# never touch current_user (Warden authenticates lazily) without authenticating them,
# and so without storing a session for them; and it applies the bearer's ceiling even when
# the request also carries a session, which Warden would otherwise prefer.
module TokenCapabilityCheck
  extend ActiveSupport::Concern

  included do
    class_attribute :token_capability_rules, instance_writer: false, default: []
    rescue_from TokenCapabilities::Denied, with: :token_capability_denied
  end

  class_methods do
    # accepts_token_capability 'class:researcher-read', only: :show, if: -> { request.get? }
    def accepts_token_capability(*capabilities, only: nil, except: nil, if: nil)
      capabilities.each { |c| TokenCapabilities.fetch(c) }
      rule = { capabilities: capabilities, only: Array(only).map(&:to_s), except: Array(except).map(&:to_s), if: binding.local_variable_get(:if) }
      self.token_capability_rules = token_capability_rules + [rule]
    end

    # Drops every declaration inherited from a superclass.
    def accepts_no_token_capabilities
      self.token_capability_rules = []
    end
  end

  protected

  def enforce_token_capabilities
    claims = PortalBearer.verified_claims(request)
    TokenScope.apply!(claims) if claims
    return unless TokenScope.scoped?
    return if (declared_token_capabilities & TokenScope.capabilities).any?
    token_capability_denied
  end

  # Passes for an unscoped credential; for a scoped one, only when the token holds
  # `capability` and, for a context-bound capability, `object` is the token's context.
  # The capability is a ceiling: callers still run their own authorization.
  def require_token_capability!(capability, object = nil)
    return true if TokenScope.allows?(capability, object)
    raise TokenCapabilities::Denied, "This token does not allow #{capability} here"
  end

  def declared_token_capabilities
    token_capability_rules.select { |rule| token_capability_rule_applies?(rule) }.flat_map { |rule| rule[:capabilities] }
  end

  def token_capability_rule_applies?(rule)
    return false if rule[:only].any? && !rule[:only].include?(action_name)
    return false if rule[:except].include?(action_name)
    rule[:if].nil? || instance_exec(&rule[:if])
  end

  def token_capability_denied(exception = nil)
    render json: { success: false, message: exception&.message || 'This token may not be used here' }, status: 403
  end
end
