#
# Dynamically generate our Role Singleton Factories for named roles:
# FactoryBot.generate :admin_role
# FactoryBot.generate :member_role
# FactoryBot.generate :guest_role
#
%w| guest member admin researcher manager author|.each_with_index do |role_name, index|
  FactoryBot.register_sequence(FactoryBot::Sequence.new(:"#{role_name}_role".to_sym) do
    Role.find_by_title(role_name) ||
        FactoryBot.create(:role, :title => role_name, :position => index)
  end)
end

##
## The actual factory for roles doesn't actually do anything at the moment.
##
FactoryBot.define do
  factory :role do

  end
end

