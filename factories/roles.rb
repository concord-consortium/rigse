
#
# Dynamically generate our Role Singleton Factories for named roles:
# Factory.next :admin_role
# Factory.next :member_role
# Factory.next :guest_role
#
%w| guest member admin researcher manager author|.each_with_index do |role_name,index|  
  Factory.sequence "#{role_name}_role".to_sym do |n| 
    role = Role.find_by_title(role_name)
    unless role
      role = Factory.create(:role, :title => role_name, :position => index)
    end
    role
  end
end


##
## The actual factory for roles doesn't actually do anything at the moment.
##
Factory.define :role do |f|

end

