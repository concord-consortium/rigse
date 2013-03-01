class PadletBookmark < Bookmark
  # include Changeable

  def self.create_for_user(user)
    found = self.for_user(user)
    return found unless found.blank?
    email  = user.email || "#{user.login}@concord.org"
    padlet = PadletWrapper.make_bookmark(email,'password')
    url    = padlet.padlet_url
    name   = "#{user.name}'s Padlet"
    made   = self.create(:user => user, :name => name, :url => url)
    return made
  end

  def self.user_can_make?(user)
    return false unless self.is_allowed?
    return self.for_user(user).blank?
  end
end