class Admin::OidcClient < ApplicationRecord
  self.table_name = 'admin_oidc_clients'

  belongs_to :user

  validates :name, presence: true
  validates :sub, presence: true, uniqueness: true
  validates :user, presence: true

  scope :active,        -> { where(active: true) }
  scope :token_minters, -> { where(can_mint_scoped_tokens: true) }
end
