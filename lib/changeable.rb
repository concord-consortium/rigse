# adds object#changeable? method which retruns true
# if user has admin or manager roles or
# if user is the author of object or
# if the object is the User object for this user
# otherwise return false
module Changeable
  
  def changeable?(user)
    
    # the Anonymous user can't change anything, always return false
    if(user.anonymous?)
      return false;
    
    # admin and manager users can change everything the system delivers to them
    elsif user.has_role?("admin", "manager") 
      true   

    # is this object a User object?
    # if so a normal User can only change their own User object                                
    elsif self.respond_to?(:user)
      if self.user == user
        true
      else
        false
      end
      
    # if this object is owned and the user is the owner return true
    elsif owned?
      self.user == user
    
    # else return false
    else
      false
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
