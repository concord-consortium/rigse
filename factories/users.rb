##
## Factories that have to do with setting up accounts.
##

##
## Emails and Logins will be derived from the sequence of 
## first names.
##
Factory.sequence(:first_name) {|n| "person_#{n}@" }

##
## Factory for user
##
Factory.define :user do |f|
  f.login   { |u| "u.first_name"}
  f.first_name  { Factory.next(:first_name) }
  f.last_name  'user' 
  f.email  { |u| "#{u.login}@concord.org"}
  f.password  'password' 
  f.password_confirmation  {|u| u.password}
  f.vendor_interface {|u| VendorInterface.find(:first) || Factory(:vendor_interface) }
  f.roles  { [Factory.next(:member_role)] }
end


##
## Singleton Factory Pattern for Admin user.
##
Factory.sequence :admin_user do |n| 
  admin = User.find_by_login('admin') 
  unless admin
    admin = Factory(:user,
    {
      :login => 'admin',
      :first_name => 'admin',
      :site_admin => 1,
      :roles => [Factory.next(:member_role),Factory.next(:admin_role)]
    })
    admin.register
    admin.activate
    admin.save!
  end
  admin
end

##
## Singleton Factory Pattern for Anonymous user.
##
Factory.sequence :anonymous_user do |n| 
  anon = User.find_by_login('anonymous') 
  unless anon
    anon = Factory(:user,
    {
      :login => 'anonymous',
      :first_name => 'anonymous',
      :roles => [Factory.next(:guest_role)]
    })
    anon.register
    anon.activate
    anon.save!
  end
  anon
end