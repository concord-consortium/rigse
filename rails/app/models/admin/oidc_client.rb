class Admin::OidcClient < ApplicationRecord
  self.table_name = 'admin_oidc_clients'

  CAPABILITIES = {
    'enroll_student'        => 'Enroll a forwarded student into a class',
    'update_offering_state' => 'Lock, hide, or open a forwarded student\'s offering',
    'send_teacher_email'    => 'Send a notification email to the student\'s teacher'
  }.freeze

  serialize :capabilities, type: Array

  belongs_to :user

  validates :name, presence: true
  validates :sub, presence: true, uniqueness: true
  validates :user, presence: true, unless: :requires_forwarded_jwt?
  validate :capabilities_are_recognized

  scope :active, -> { where(active: true) }

  def capability?(name)
    (capabilities || []).include?(name.to_s)
  end

  private

  def capabilities_are_recognized
    unknown = (capabilities || []) - CAPABILITIES.keys
    return if unknown.empty?
    errors.add(:capabilities, "contains unknown capabilities: #{unknown.join(', ')}")
  end
end
