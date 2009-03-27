# adds object#changeable? method which retruns true
# if user has admin or manager roles or
# if user is the author of object. 
module Changeable
  def changeable?(user)
    if user.roles.find_by_title('admin') || user.roles.find_by_title('manager')
      true
    elsif self.respond_to?(:user) && self.user == user
      true
    elsif self == user
      true
    else
      nil
    end
  end
end