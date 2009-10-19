# modifies object#changeable? method for changeable objects 
# in a portal Context.
# TODO: this should be built with more thorough policies
# if the entity is a 'virtual' entity, we implement normal changable rules.
# (see Changeable.rb) -- otherwise we 
# otherwise return false
module DistrictChangeable
  include Changeable
  
  alias _changeable? changeable?
  def changeable?(user)
    unless real?
      return _changeable?
    end
    if user.has_role?('manager','admin','district_admin')
      return true
    end
    return false
  end
 
end
