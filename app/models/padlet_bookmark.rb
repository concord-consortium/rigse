class PadletBookmark < Bookmark
  # include Changeable

  def self.for_user(user)
    found = self.find_by_user_id(user) || create_for_user(user)
    found.touch
  end

  def self.create_for_user(user)
    padlet = PadletHelper.make_bookmark
    url    = padlet.padlet_url
    name   = "#{user.name}'s Padlet"
    self.create(:user => user, :name => name, :url => url)
  end

  def self.viewTemplate

  end
end
