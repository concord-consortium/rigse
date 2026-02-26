class LearnerDetailPolicy < ApplicationPolicy

  # Previously authorized via request_is_peer? (LARA sent Bearer app_secret).
  # LARA's learner_detail caller is confirmed dead (zero traffic over 365 days).
  # Disabled as part of peer-to-peer auth removal; see
  # docs/specs/peer-to-peer-auth-removal-research.md
  def show?
    false
  end
end
