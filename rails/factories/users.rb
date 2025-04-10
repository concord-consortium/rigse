##
## Factories that have to do with setting up accounts.
##

##
## Factory for user
##
FactoryBot.define do
  factory :user do
    login {"login_#{UUIDTools::UUID.timestamp_create.to_s[0..20]}"}
    first_name {'joe'}
    last_name {'user'}
    email {"#{login}@concord.org"}
    password {'password'}
    password_confirmation {|u| u.password}
    skip_notifications {true}
    require_password_reset {false}
    roles {[FactoryBot.generate(:member_role)]}
  end
end

FactoryBot.define do
  factory :confirmed_user, :parent => :user do
    after(:create) {|user| user.confirm}
  end
end

##
## Singleton Factory Pattern for Admin user.
##
FactoryBot.define do
  sequence(:admin_user) do
    admin = User.find_by_login('admin')
    unless admin
      admin = FactoryBot.create(:user,
                                {
                                    :login => 'admin',
                                    # :password =>'password',  # all passwords are 'password' (defined in user factory)
                                    :first_name => 'admin',
                                    :site_admin => 1,
                                    :roles => [FactoryBot.generate(:member_role), FactoryBot.generate(:admin_role)]
                                })
      admin.save!
      admin.confirm
      admin.add_role('admin')
    end
    admin
  end
end

##
## Singleton Factory Pattern for Researcher user.
##
FactoryBot.define do
  sequence(:researcher_user) do
    researcher = User.find_by_login('researcher')
    unless researcher
      researcher = FactoryBot.create(:user,
                                    {
                                        :login => 'researcher',
                                        # :password =>'password',  # all passwords are 'password' (defined in user factory)
                                        :first_name => 'researcher',
                                        :site_admin => 0,
                                        :roles => [FactoryBot.generate(:member_role), FactoryBot.generate(:researcher_role)]
                                    })
      researcher.save!
      researcher.confirm
      researcher.add_role('researcher')
    end
    researcher
  end
end

##
## Singleton Factory Pattern for Researcher user.
##
FactoryBot.define do
  sequence(:manager_user) do
    manager = User.find_by_login('manager')
    unless manager
      manager = FactoryBot.create(:user,
                                  {
                                      :login => 'manager',
                                      # :password =>'password',  # all passwords are 'password' (defined in user factory)
                                      :first_name => 'manager',
                                      :site_admin => 1,
                                      :roles => [FactoryBot.generate(:member_role), FactoryBot.generate(:manager_role)]
                                  })
      manager.save!
      manager.confirm
      manager.add_role('manager')
    end
    manager
  end
end

##
## Singleton Factory Pattern for Researcher user.
##
FactoryBot.define do
  sequence(:author_user) do
    author = User.find_by_login('author')
    unless author
      author = FactoryBot.create(:user,
                                {
                                    :login => 'author',
                                    # :password =>'password',  # all passwords are 'password' (defined in user factory)
                                    :first_name => 'author',
                                    :site_admin => 0,
                                    :roles => [FactoryBot.generate(:member_role), FactoryBot.generate(:author_role)]
                                })
      author.save!
      author.confirm
      author.add_role('author')
    end
    author
  end
end

##
## Singleton Factory Pattern for Anonymous user.
##
FactoryBot.define do
  sequence(:anonymous_user) do
    anon = nil
    begin
      anon = User.find_by_login('anonymous')
      unless anon
        anon = FactoryBot.create(:user,
                                {
                                    :login => 'anonymous',
                                    :first_name => 'anonymous',
                                    :roles => [FactoryBot.generate(:guest_role)]
                                })
        anon.save!
        anon.confirm
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
end

FactoryBot.generate(:anonymous_user)
