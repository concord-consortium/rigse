class FirebaseApp < ApplicationRecord
  self.table_name = :firebase_apps

  validates_presence_of :name, :message => "can't be blank"
  validates_format_of :client_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, :message => 'is not a valid email address'
  validates_presence_of :private_key, :message => "can't be blank"

  validate :is_valid_private_key?

  before_save :replace_newlines_in_private_key

  private

  def is_valid_private_key?
    if !private_key.blank?
      escaped_private_key = replace_newlines(private_key)
      if !SignedJwt::is_valid_private_key?(escaped_private_key)
        errors.add(:private_key, "is not valid (attempted signing failed)")
      end
    end
  end

  def replace_newlines_in_private_key
    self.private_key = replace_newlines(self.private_key)
  end

  # the credentials.json file that Firebase provides has newlines embedded
  # in the private_key value - these need to become real newlines in the database
  def replace_newlines(s)
    (s || "").gsub('\n', "\n")  # single quoted strings in Ruby are literals, double quoted are escaped
  end
end
