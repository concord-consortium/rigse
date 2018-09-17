##
## Factories that have to do with setting up accounts.
##

##
## Factory for user
##
FactoryGirl.define do
  factory :user do
    login {"login_#{UUIDTools::UUID.timestamp_create.to_s[0..20]}"}
    first_name 'joe'
    last_name 'user'
    email {|u| "#{u.login}@concord.org"}
    password 'password'
    password_confirmation {|u| u.password}
    skip_notifications true
    require_password_reset false
    roles {[FactoryGirl.generate(:member_role)]}
  end
end

FactoryGirl.define do
  factory :confirmed_user, :parent => :user do
    after(:create) {|user| user.confirm!}
  end
end

##
## Singleton Factory Pattern for Admin user.
##
FactoryGirl.register_sequence(FactoryGirl::Sequence.new(:admin_user) do
  admin = User.find_by_login('admin')
  unless admin
    admin = FactoryGirl.create(:user,
                               {
                                   :login => 'admin',
                                   # :password =>'password',  # all passwords are 'password' (defined in user factory)
                                   :first_name => 'admin',
                                   :site_admin => 1,
                                   :roles => [FactoryGirl.generate(:member_role), FactoryGirl.generate(:admin_role)]
                               })
    admin.save!
    admin.confirm!
    admin.add_role('admin')
  end
  admin
end
)

##
## Singleton Factory Pattern for Researcher user.
##
FactoryGirl.register_sequence(FactoryGirl::Sequence.new(:researcher_user) do
  researcher = User.find_by_login('researcher')
  unless researcher
    researcher = FactoryGirl.create(:user,
                                    {
                                        :login => 'researcher',
                                        # :password =>'password',  # all passwords are 'password' (defined in user factory)
                                        :first_name => 'researcher',
                                        :site_admin => 0,
                                        :roles => [FactoryGirl.generate(:member_role), FactoryGirl.generate(:researcher_role)]
                                    })
    researcher.save!
    researcher.confirm!
    researcher.add_role('researcher')
  end
  researcher
end
)

##
## Singleton Factory Pattern for Researcher user.
##
FactoryGirl.register_sequence(FactoryGirl::Sequence.new(:manager_user) do
  manager = User.find_by_login('manager')
  unless manager
    manager = FactoryGirl.create(:user,
                                 {
                                     :login => 'manager',
                                     # :password =>'password',  # all passwords are 'password' (defined in user factory)
                                     :first_name => 'manager',
                                     :site_admin => 1,
                                     :roles => [FactoryGirl.generate(:member_role), FactoryGirl.generate(:manager_role)]
                                 })
    manager.save!
    manager.confirm!
    manager.add_role('manager')
  end
  manager
end
)
##
## Singleton Factory Pattern for Researcher user.
##
FactoryGirl.register_sequence(FactoryGirl::Sequence.new(:author_user) do
  author = User.find_by_login('author')
  unless author
    author = FactoryGirl.create(:user,
                                {
                                    :login => 'author',
                                    # :password =>'password',  # all passwords are 'password' (defined in user factory)
                                    :first_name => 'author',
                                    :site_admin => 0,
                                    :roles => [FactoryGirl.generate(:member_role), FactoryGirl.generate(:author_role)]
                                })
    author.save!
    author.confirm!
    author.add_role('author')
  end
  author
end
)

##
## Singleton Factory Pattern for Anonymous user.
##
FactoryGirl.register_sequence(FactoryGirl::Sequence.new(:anonymous_user) do
  anon = nil
  begin
    anon = User.find_by_login('anonymous')
    unless anon
      anon = FactoryGirl.create(:user,
                                {
                                    :login => 'anonymous',
                                    :first_name => 'anonymous',
                                    :roles => [FactoryGirl.generate(:guest_role)]
                                })
      anon.save!
      anon.confirm!
      # clear any previous Anonymous user still cached as a class variable in the User class
      User.anonymous(true)
      anon.save!
      anon.add_role('guest')

    end
    anon
  rescue StandardError
    nil
  end
end
)

FactoryGirl.generate(:anonymous_user)
