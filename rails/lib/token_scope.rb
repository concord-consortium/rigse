# Reads the per-request facts a verified portal token carries (its scope, its context and
# the service-mint marker) onto Current. The global capability check, the Devise JWT
# strategy and check_for_auth_token all go through here, so the three can never disagree
# about what a token may do.
module TokenScope
  # Copies a verified token's claims onto Current. `data` is the decoded payload.
  def self.apply!(data)
    Current.minted_via_oidc_client_id = data['minted_via_oidc_client_id']
    Current.minted_for                = data['minted_for']
    scope = data['scope']
    Current.token_scope   = scope.nil? ? nil : TokenCapabilities.parse(scope)
    Current.token_context = parse_context(data['context'])
  end

  # Whether the request's credential carries a scope, and so a ceiling.
  def self.scoped?
    !Current.token_scope.nil?
  end

  def self.capabilities
    Current.token_scope || []
  end

  # The scope and context a token minted during this request inherits, as it inherits the
  # service-mint marker.
  def self.inherited_claims
    return {} unless scoped?
    claims = { scope: capabilities.join(' ') }
    claims[:context] = Current.token_context if Current.token_context
    claims
  end

  # True when the credential allows `capability` on `object`. An unscoped credential always
  # does; a scoped one only when it holds the capability and, for a context-bound one,
  # `object` is the token's context. A scoped token without a context fails every
  # context-bound check, so it can never pass as an unrestricted caller.
  def self.allows?(capability, object = nil)
    return true unless scoped?
    return false unless capabilities.include?(capability)
    context_type = TokenCapabilities.fetch(capability).context_type
    return true if context_type.nil?
    context = Current.token_context
    context.present? && context['type'] == context_type && object.present? &&
      TokenCapabilities.context_type_for(object) == context_type && context['id'] == object.id
  end

  def self.parse_context(context)
    return nil unless context.is_a?(Hash)
    type, id = context['type'], context['id']
    return nil unless type.is_a?(String) && id.is_a?(Integer)
    { 'type' => type, 'id' => id }
  end
  private_class_method :parse_context
end
