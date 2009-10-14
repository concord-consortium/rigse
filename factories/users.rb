Factory.sequence(:email) {|n| "somebody_#{n}@concord.org" }

Factory.define :user do |f|
  f.first_name  'Anonymous' 
  f.last_name  'User' 
  f.email  { Factory.next(:email) }
  f.password  'password' 
  f.password_confirmation  {|u| u.password}
  f.vendor_interface {|u| VendorInterface.find(:first) || Factory(:vendor_interface) }
end

