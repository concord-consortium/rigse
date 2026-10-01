class Current < ActiveSupport::CurrentAttributes
  attribute :minted_via_oidc_client_id, :minted_for
  # Set by TokenScope from a verified token: its capabilities (nil for an unscoped
  # credential) and the one object it is bound to, as {"type" => ..., "id" => ...}.
  attribute :token_scope, :token_context
end
