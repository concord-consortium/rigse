class Portal::PadletBookmark < Portal::Bookmark
  default_scope :order => 'position'

  def self.create_for_user(user, clazz = nil)
    return false if user.anonymous?
    found  = self.for_user(user)
    padlet = PadletWrapper.new
    url    = padlet.padlet_url
    count  = found.size
    numbers = found.map do |item|
      match = item.name.match(/my\s+(\d+)(rd|st|nd|th)\s+padlet/i)
      match = match ? match[1].to_i : nil
    end
    numbers.compact!
    if numbers.max
      count = numbers.max if (numbers.max > count)
    end
    ordinal = (count + 1).ordinalize
    name = "My #{ordinal} Padlet"
    made = self.create(:user => user, :name => name, :url => url)
    made.clazz = clazz
    made.save!
    return made
  end

  def self.user_can_make?(user)
    return false unless self.is_allowed?
    return false if user.anonymous?
    return true
  end
end
