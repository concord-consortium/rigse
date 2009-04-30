# adds object#changeable? method which retruns true
# if user has admin or manager roles or
# if user is the author of object. 
module Changeable
  def changeable?(user)
    if user.roles.find_by_title('admin') || user.roles.find_by_title('manager')
      true
    elsif self.respond_to?(:user) 
      if self.user == user
        true
      # any one can change an anonymous item(??)
      elsif self.un_owned?
        true
      end
    elsif self == user
      true
    else
      nil
    end
  end
  
  def owned?
    if self.user.nil?
      return false
    end
    if self.user.anonymous?
      return false
    end
    true
  end
  
  def un_owned?
    return (! self.owned?)
  end
end