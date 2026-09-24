class Current < ActiveSupport::CurrentAttributes
  attribute :minted_via_oidc_client_id, :minted_for
  # What an RS256 bearer says it was launched for. A record of the launch, never a grant:
  # every use re-runs the permission check on the scope.
  attribute :token_scope_kind, :token_scope_id
end
