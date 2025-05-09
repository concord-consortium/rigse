class Admin::AutoExternalActivityRule < ApplicationRecord
  belongs_to :user, foreign_key: :user_id
  has_and_belongs_to_many :external_reports, join_table: :auto_external_activity_rules_external_reports

  validates :name, :slug, :description, :allow_patterns, presence: true
  validates :slug, uniqueness: true
  validates :slug, format: { with: /\A[\w-]+\z/, message: "can only contain letters, numbers, underscores, and dashes" }

  validate :user_must_be_author
  validate :allow_patterns_must_be_valid_regex

  def matches_pattern?(url)
    # Split allow_patterns on newlines and check if any pattern matches the URL
    allow_patterns.split("\n").any? do |pattern|
      regex = Regexp.new(pattern)
      regex.match?(url)
    end
  end

  private

  def user_must_be_author
    if !user
      errors.add(:user_id, "must be present")
    elsif !user.has_role?("author")
      errors.add(:user_id, "must be a user with the 'author' role")
    end
  end

  def allow_patterns_must_be_valid_regex
    return if allow_patterns.blank?

    patterns = allow_patterns.split("\n").map(&:strip).reject(&:blank?)
    if patterns.empty?
      errors.add(:allow_patterns, "must include at least one valid pattern")
      return
    end

    patterns.each_with_index do |pattern, index|
      begin
        Regexp.new(pattern)
      rescue RegexpError => e
        errors.add(:allow_patterns, "pattern on line #{index + 1} is invalid: #{e.message}")
      end
    end
  end
end
