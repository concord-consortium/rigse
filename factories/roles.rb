#
# Dynamically generate our Role Singleton Factories for named roles:
# FactoryGirl.generate :admin_role
# FactoryGirl.generate :member_role
# FactoryGirl.generate :guest_role
#
%w| guest member admin researcher manager author|.each_with_index do |role_name, index|
  FactoryGirl.register_sequence(FactoryGirl::Sequence.new(:"#{role_name}_role".to_sym) do
    Role.find_by_title(role_name) ||
        FactoryGirl.create(:role, :title => role_name, :position => index)
  end)
end

##
## The actual factory for roles doesn't actually do anything at the moment.
##
FactoryGirl.define do
  factory :role do

  end
end

