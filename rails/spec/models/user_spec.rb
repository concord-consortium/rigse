# -*- coding: utf-8 -*-
require File.expand_path('../../spec_helper', __FILE__)

describe User do
  fixtures :users

  describe 'being created' do
    before do
      @user = nil
      @creating_user = lambda do
        @user = create_user
        violated "#{@user.errors.full_messages.to_sentence}" if @user.new_record?
      end
    end

    it 'increments User#count' do
      expect(@creating_user).to change(User, :count).by(1)
    end

    it 'initializes #activation_code' do
      @creating_user.call
      @user.reload
      expect(@user.confirmation_token).not_to be_nil
    end

    it 'starts in pending state' do
      @creating_user.call
      @user.reload
      expect(@user.state).to eq('pending')
    end
  end

  #
  # Validations
  #

  it 'requires login' do
    expect do
      u = create_user(:login => nil)
      expect(u.errors[:login]).not_to be_nil
    end.not_to change(User, :count)
  end

  describe 'allows legitimate logins:' do
    ['123', '1234567890_234567890_234567890_234567890',
     'hello.-_there@funnychar.com'].each do |login_str|
      it "'#{login_str}'" do
        expect do
          u = create_user(:login => login_str)
          expect(u.errors[:login]).to eq([])
        end.to change(User, :count).by(1)
      end
    end
  end

  describe 'disallows illegitimate logins:' do
    ['', '1234567890_234567890_234567890_234567890_',
     "Iñtërnâtiônàlizætiøn hasn't happened to ruby 1.8 yet",
     'semicolon;', 'quote"', 'backtick`', 'percent%'].each do |login_str|
      it "'#{login_str}'" do
        expect do
          u = create_user(:login => login_str)
          expect(u.errors[:login]).not_to be_nil
        end.not_to change(User, :count)
      end
    end
  end

  it 'requires password' do
    expect do
      u = create_user(:password => nil)
      expect(u.errors[:password]).not_to be_nil
    end.not_to change(User, :count)
  end

  it 'requires password confirmation' do
    expect do
      u = create_user(:password_confirmation => nil)
      expect(u.errors[:password_confirmation]).not_to be_nil
    end.not_to change(User, :count)
  end

  it 'requires email' do
    expect do
      u = create_user(:email => nil)
      expect(u.errors[:email]).not_to be_nil
    end.not_to change(User, :count)
  end

  describe 'allows legitimate emails:' do
    ['foo@bar.com', 'foo@newskool-tld.museum', 'foo@twoletter-tld.de', 'foo@nonexistant-tld.qq',
     'r@a.wk', '1234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890@gmail.com',
     'hello.-_there@funnychar.com', 'uucp%addr@gmail.com', 'hello+routing-str@gmail.com',
     'domain@can.haz.many.sub.doma.in', 'student.name@university.edu'
    ].each do |email_str|
      it "'#{email_str}'" do
        expect do
          u = create_user(:email => email_str)
          expect(u.errors[:email]).to eq([])
        end.to change(User, :count).by(1)
      end
    end
  end

  describe 'disallows illegitimate emails' do
    ['!!@nobadchars.com', 'foo@no-rep-dots..com', 'foo@badtld.xxx', 'foo@toolongtld.abcdefg',
     'Iñtërnâtiônàlizætiøn@hasnt.happened.to.email', 'need.domain.and.tld@de',
     'r@.wk', '1234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890@gmail2.com',
     # these are technically allowed but not seen in practice:
     # Update: just saw a tick in the wild, modified validations
     # see commit: 1e9d396b0
     # 'tick\'@gmail.com' now allowed.
     'uucp!addr@gmail.com', 'semicolon;@gmail.com', 'quote"@gmail.com', 'backtick`@gmail.com', 'space @gmail.com', 'bracket<@gmail.com', 'bracket>@gmail.com'
    ].each do |email_str|
      it "'#{email_str}'" do
        expect do
          u = create_user(:email => email_str)
          expect(u.errors[:email]).not_to be_nil
        end.not_to change(User, :count)
      end
    end
  end

  describe 'allows legitimate names:' do
    ['Andre The Giant (7\'4", 520 lb.) -- has a posse',
     'ᛅᛁᛚᛁᚠᚱ',
     '1234567890k',
    ].each do |name_str|
      it "'#{name_str}'" do
        expect do
          u = create_user(:first_name => name_str)
          expect(u.errors[:first_name]).to eq([])
        end.to change(User, :count).by(1)
      end
    end
  end
  describe "disallows illegitimate names" do
    ['1234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_',
     ].each do |name_str|
      it "'#{name_str}'" do
        expect do
          u = create_user(:first_name => name_str)
          expect(u.errors[:first_name]).not_to be_nil
        end.not_to change(User, :count)
      end
    end
  end

  it 'resets password' do
    users(:quentin).update_attributes({:password => 'new password', :password_confirmation => 'new password'})
    expect(User.authenticate('quentin', 'new password')).to eq(users(:quentin))
  end

  it 'does not rehash password' do
    users(:quentin).update_attributes({:login => 'quentin2'})
    expect(User.authenticate('quentin2', 'monkey')).to eq(users(:quentin))
  end

  #
  # Authentication
  #

  it 'authenticates user' do
    expect(User.authenticate('quentin', 'monkey')).to eq(users(:quentin))
  end

  it "doesn't authenticate user with bad password" do
    expect(User.authenticate('quentin', 'invalid_password')).to be_nil
  end

  #
  # Authentication
  #

  it 'sets remember token' do
    users(:quentin).remember_me!
    expect(users(:quentin).remember_token).not_to be_nil
    expect(users(:quentin).remember_created_at).not_to be_nil
  end

  it 'unsets remember token' do
    users(:quentin).remember_me!
    expect(users(:quentin).remember_token).not_to be_nil
    users(:quentin).forget_me
    expect(users(:quentin).remember_token).to be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.ago.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    expect(users(:quentin).remember_token).not_to be_nil
    expect(users(:quentin).remember_created_at).not_to be_nil
    expect(users(:quentin).remember_created_at.between?(before, after)).to be_truthy
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    expect(users(:quentin).remember_token).not_to be_nil
    expect(users(:quentin).remember_created_at).not_to be_nil
    expect(users(:quentin).remember_created_at.utc.to_s(:db)).to eq(time.to_s(:db))
  end

  it 'remembers me default two weeks' do
    before = 2.weeks.ago.utc
    users(:quentin).remember_me!
    after = 2.weeks.from_now.utc
    expect(users(:quentin).remember_token).not_to be_nil
    expect(users(:quentin).remember_created_at).not_to be_nil
    expect(users(:quentin).remember_created_at.between?(before, after)).to be_truthy
  end

  it 'registers passive user' do
    user = create_user(:password => nil, :password_confirmation => nil)
    expect(user.state).to eq('passive')
    user.update_attributes({:password => 'new password', :password_confirmation => 'new password'})
    user.save!
    user.reload
    expect(user.state).to eq('pending')
  end

  it 'suspends user' do
    users(:quentin).suspend!
    expect(users(:quentin).state).to eq('suspended')
  end

  it 'does not authenticate suspended user' do
    users(:quentin).suspend!
    expect(User.authenticate('quentin', 'monkey')).not_to eq(users(:quentin))
  end

  it 'deletes user' do
    expect(users(:quentin).deleted_at).to be_nil
    users(:quentin).delete!
    expect(users(:quentin).deleted_at).not_to be_nil
    expect(users(:quentin).state).to eq('disabled')
  end

  describe "being unsuspended" do
    fixtures :users

    before do
      @user = users(:quentin)
      @user.suspend!
    end

    it 'reverts to active state' do
      @user.unsuspend!
      expect(@user.state).to eq('active')
    end

    it 'reverts to passive state if activation_code and activated_at are nil' do
      User.update_all({:confirmation_token => nil, :confirmed_at => nil})
      @user.reload.unsuspend!
      expect(@user.state).to eq('passive')
    end

    it 'reverts to pending state if activation_code is set and activated_at is nil' do
      count = 1
      User.all.each do |user|
        user.update_attribute(:confirmation_token, "foo-bar-#{count}")
        user.update_attribute(:confirmed_at, nil)
        count = count + 1
        user.save!
      end
      @user.reload.unsuspend!
      expect(@user.state).to eq('pending')
    end
  end

  # Access token generation
  describe 'generated access token' do
    let(:quentin_token) { users(:quentin).create_access_token_valid_for(1.day) }
    let(:aaron_token)   { users(:aaron).create_access_token_valid_for(1.day) }

    it 'can be used to authenticate and get correct user' do
      conditions = { User.token_authentication_key => quentin_token }
      expect(User.find_for_token_authentication(conditions)).to eql(users(:quentin))
      conditions = { User.token_authentication_key => aaron_token }
      expect(User.find_for_token_authentication(conditions)).to eql(users(:aaron))
    end
  end

  # Security questions, currently for Students only

  describe "security questions" do
    before(:each) do
      @user = users(:quentin)
    end

    it "updates security questions" do
      questions = Array.new(3) { |i| SecurityQuestion.new({ :question => "test #{i}", :answer => "test" }) }

      expect(@user.security_questions).to be_empty

      @user.update_security_questions!(questions)

      expect(@user.security_questions.size).to eq(3)
      questions.each do |v|
        expect(@user.security_questions.select { |q| q.question == v.question && q.answer == v.answer }.size).to eq(1)
      end
    end
  end

  describe "checking for logins" do
    describe "when available" do
      before(:each) do
        expect(User).to receive(:login_exists?).with("hpotter").and_return(false)
      end
      it "should return the first initial and last name" do
        expect(User.suggest_login('Harry','Potter')).to eq("hpotter")
      end
    end
    describe "when not available" do
      it "should append a counter number to the default login" do
        expect(User).to receive(:login_exists?).once.with("hpotter").ordered.and_return(true)
        expect(User).to receive(:login_exists?).once.with("hpotter1").ordered.and_return(true)
        expect(User).to receive(:login_exists?).once.with("hpotter2").ordered.and_return(true)
        expect(User).to receive(:login_exists?).once.with("hpotter3").ordered.and_return(false)
        expect(User.suggest_login('Harry','Potter')).to eq("hpotter3")
      end
    end
  end

  describe "require_reset_password" do
    before(:each) do
      @user = create_user(:login => 'default_user', :email => 'nobody@noplace.com')
    end
    describe "freshly minted user" do
      it "will not require the password to be reset" do
        expect(@user.require_password_reset).to be_falsey
      end
    end
  end

  describe "add_role_for_project" do
    let(:project)     { FactoryBot.create(:project) }
    let(:user)        { FactoryBot.create(:user)    }

    before(:each) do
      user.add_role_for_project('admin', project)
    end

    it "should be a project admin for the project now " do
      expect(user.is_project_admin?(project)).to eq true
    end

    describe "when a user was previously an admin for the project" do
      before(:each) do
        user.add_role_for_project('admin', project)
      end
      it "should still be an admin of the project " do
        expect(user.is_project_admin?(project)).to eq true
      end
      it "should only be admin for one project" do
        expect(user.admin_for_projects.size).to eq(1)
      end
    end
  end

  describe "remove_role_for_project" do
    let(:project)     { FactoryBot.create(:project) }
    let(:user)        { FactoryBot.create(:user)    }

    describe "when a user was previously an admin for the project" do
      before(:each) do
        user.add_role_for_project('admin', project)
      end
      it "the user is no longer an admin for the project" do
        user.remove_role_for_project("admin",project)
        expect(user.is_project_admin?(project)).to eq false
      end
    end

    describe "when a user wasnt previously an admin for the project" do
      it "the user is still not an admin for the project" do
        user.remove_role_for_project("admin",project)
        expect(user.is_project_admin?(project)).to eq false
      end
      it "should only be admin for no projects" do
        expect(user.admin_for_projects.size).to eq(0)
      end
    end
  end

  describe "set_role_for_projects" do
    let(:projects)         { 5.times.map { |i|  FactoryBot.create(:project, name: "project_#{i}")}  }
    let(:user)             { FactoryBot.create(:user)    }
    let(:selected_projects){ [ projects.first] }

    before(:each) do
      user.set_role_for_projects('admin', projects, selected_projects.map(&:id) )
    end

    it "should be a project admin for the first project now " do
      expect(user.is_project_admin?(projects.first)).to eq true
    end

    it "should list one admin_project" do
      expect(user.admin_for_projects.size).to eq(1)
      expect(user.admin_for_projects).to include(projects.first)
    end

  end

  describe "find_for_omniauth" do
    it "finds user with matching authentication" do
      authentication = FactoryBot.create :authentication
      user = authentication.user
      mock_auth = double(provider: authentication.provider, uid: authentication.uid)
      found_user = User.find_for_omniauth(mock_auth)
      expect(found_user).to eq user
    end
    context "when a user exists with the same email" do
      let(:user) { FactoryBot.create :confirmed_user }
      let(:mock_auth) {
        double(provider: "fake_provider", uid: "fake_uid",
          info: double(email: user.email))
      }
      before(:each) {
        # make sure user is created
        user
      }
      it "throws an error if the user is a student" do
        student = FactoryBot.create :portal_student, user: user
        expect {
          User.find_for_omniauth(mock_auth)
        }.to raise_error(/persisted email/)
      end
      context "when the user isn't a student" do
        it "creates an authentication if one doesn't exist" do
          expect(user.authentications.size).to eq(0)
          found_user = User.find_for_omniauth(mock_auth)
          expect(found_user).to eq user
          new_authentication = found_user.authentications.first
          expect(new_authentication.provider).to eq(mock_auth.provider)
          expect(new_authentication.uid).to eq(mock_auth.uid)
        end
        it "doesn't create an authentication if one exists" do
          authentication = FactoryBot.create :authentication,
            user: user, provider: mock_auth.provider
          user.reload
          found_user = nil
          expect {
            found_user = User.find_for_omniauth(mock_auth)
            user.reload
          }.to_not change{ user.authentications.to_a }

          expect(found_user).to eq user
        end
      end

    end
    context "when a user does not exists with the same email" do
      let(:mock_auth) {
        double(provider: "fake_provider", uid: "fake_uid",
          info: double(email: "fake_email@example.com"),
          extra: double(first_name: "Fake", last_name: "Name"))
      }
      it "creates a new user" do
        new_user = User.find_for_omniauth(mock_auth)
        expect(new_user.first_name).to eq("Fake")
        expect(new_user.last_name).to eq("Name")
      end
    end

  end

protected
  def create_user(options = {})
    record = User.new({ :first_name => "foo",
                        :last_name  => "bar",
                        :login      => 'quire',
                        :email      => 'quire@example.com',
                        :password   => 'quire69',
                        :password_confirmation => 'quire69' }.merge(options))
    record.save! if record.valid?
    record
  end

  describe 'user scopes' do
    # There are 3 users already loaded from fixtures in:

    # rails/spec/fixtures/users.yml
    # ID: email, state:
    # 1: quentin@example.com, active
    # 2: aaron@example.com, pending
    # 3: salty_dog@example.com, active

    let(:quentin) { User.find(1) }
    let(:arron)   { User.find(2) }
    let(:salty)   { User.find(3) }
    let(:all_our_users) { [arron, salty, quentin] }

    let(:saltys_state) { 'pending' }
    let(:limit) { 3 }

    # For scope tests, all users will be set as 'active'
    before(:each) do
      all_our_users.each do |u|
        u.update_attribute(:state, 'active')
      end
      # Saltys state will be changed to tests scopes
      salty.update_attribute('state', saltys_state)
    end

    describe '.all_users' do # scope test
      let(:scope) { 'all_users' }
      let(:saltys_state) { 'pending' }
      subject { User.all_users.limit(limit) }
      it 'returns all users despite status' do
        expect(subject).to all(be_a(described_class))
      end
      it 'should include all of our users' do
        all_our_users.each do |user|
          expect(subject).to include(user)
        end
      end
    end

    describe '.active' do
      let(:saltys_state) { 'pending' }
      subject { User.active.limit(limit) }
      it 'should be active users only' do
        expect(subject).to include(quentin)
        expect(subject).to include(arron)
        expect(subject).not_to include(salty)
      end
    end

    describe '.suspended' do
      let(:saltys_state) { 'suspended' }
      let(:scope) { 'suspended' }
      subject { User.suspended.limit(limit) }
      it 'limits to suspended users' do
        expect(subject).not_to include(quentin)
        expect(subject).not_to include(arron)
        expect(salty.state).to eq('suspended')
        expect(subject).to include(salty)
      end
    end

    describe '.no_email' do # scope test
      before(:each) do
        salty.update_attribute(
          :email, "#{User::NO_EMAIL_STRING}-12@#{User::NO_EMAIL_DOMAIN}"
        )
      end
      subject { User.no_email.limit(limit) }
      it 'limits to users with fake email addresses' do
        expect(subject).not_to include(quentin)
        expect(subject).not_to include(arron)
        expect(subject).to include(salty)
      end
    end

    describe '.email' do # scope test
      before(:each) do
        salty.update_attribute(:email,
          "#{User::NO_EMAIL_STRING}-12@#{User::NO_EMAIL_DOMAIN}"
        )
      end
      subject { User.email.limit(limit) }
      it 'limits to users with fake email addresses' do
        expect(subject).to include(quentin)
        expect(subject).to include(arron)
        expect(subject).not_to include(salty)
      end
    end

    # TODO: NB: This name is unfortunate, it is too similar to default_scope!
    # Though the names are similar this scope searches for `default` users.
    describe '.default' do # scope test
      subject { User.default.limit(limit) }
      before(:each) { salty.update_attribute(:default_user, true) }
      it 'returns only users with :default set to true' do
        expect(described_class.limit(limit).default).to all(be_a(described_class))
      end
    end

    describe '.with_role' do # scope test
      let(:role_name) { 'role_name' }
      before(:each) { salty.add_role(role_name) }
      subject { User.with_role(role_name).limit(limit) }
      it 'returns users with matching roles' do
        expect(subject).not_to include(quentin)
        expect(subject).not_to include(arron)
        expect(subject).to include(salty)
      end
    end
  end


  # TODO: auto-generated
  describe '#apply_omniauth' do
    xit 'apply_omniauth' do
      user = described_class.new
      omniauth = double('omniauth')
      result = user.apply_omniauth(omniauth)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.find_for_token_authentication' do
    it 'find_for_token_authentication' do
      conditions = {}
      result = described_class.find_for_token_authentication(conditions)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#strip_spaces' do
    it 'strip_spaces' do
      user = described_class.new
      result = user.strip_spaces

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.login_regex' do
    it 'login_regex' do
      result = described_class.login_regex

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.name_regex' do
    it 'name_regex' do
      result = described_class.name_regex

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.searchable_attributes' do
    it 'searchable_attributes' do
      result = described_class.searchable_attributes

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.login_exists?' do
    it 'login_exists?' do
      login = 'login'
      result = described_class.login_exists?(login)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.login_does_not_exist?' do
    it 'login_does_not_exist?' do
      login = double('login')
      result = described_class.login_does_not_exist?(login)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.suggest_login' do
    it 'suggest_login' do
      first = double('first')
      last = double('last')
      result = described_class.suggest_login('first', 'last')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.default_users' do
    it 'default_users' do
      result = described_class.default_users

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.suspend_default_users' do
    it 'suspend_default_users' do
      result = described_class.suspend_default_users

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.unsuspend_default_users' do
    it 'unsuspend_default_users' do
      result = described_class.unsuspend_default_users

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.site_admin' do
    it 'site_admin' do
      result = described_class.site_admin

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '.find_for_omniauth' do
    xit 'find_for_omniauth' do
      auth = double('auth')
      signed_in_resource = double('signed_in_resource')
      result = described_class.find_for_omniauth(auth, signed_in_resource)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#removed_investigation' do
    it 'removed_investigation' do
      user = described_class.new
      result = user.removed_investigation

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#has_investigations?' do
    it 'has_investigations?' do
      user = described_class.new
      result = user.has_investigations?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.authenticate' do
    it 'authenticate' do
      login = double('login')
      password = double('password')
      result = described_class.authenticate(login, password)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#create_access_token_valid_for' do
    xit 'create_access_token_valid_for' do
      user = described_class.new
      time = 2.days
      result = user.create_access_token_valid_for(time)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#create_access_token_with_learner_valid_for' do
    xit 'create_access_token_with_learner_valid_for' do
      user = described_class.new
      time = 2.days
      result = user.create_access_token_with_learner_valid_for(time, Portal::Learner.new)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#active_for_authentication?' do
    it 'active_for_authentication?' do
      user = described_class.new
      result = user.active_for_authentication?

      expect(result).to be_nil
    end
  end

  describe '#finish_enews_subscription' do
    it 'finish_enews_subscription' do
      expect(EnewsSubscription).to receive(:set_status).and_return({subscribed: 'subscribed'})
      user = create_user(
        :email_subscribed => true
      )
      result = user.finish_enews_subscription

      expect(result).to eq({:subscribed=>'subscribed'})
    end
  end

  # TODO: auto-generated
  describe '#confirm!' do
    it 'confirm!' do
      user = described_class.new
      result = user.confirm!

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#inactive_message' do
    it 'inactive_message' do
      user = described_class.new
      result = user.inactive_message

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#is_oauth_user?' do
    it 'is_oauth_user?' do
      user = described_class.new
      result = user.is_oauth_user?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#name' do
    it 'name' do
      user = described_class.new
      result = user.name

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#name_and_login' do
    it 'name_and_login' do
      user = described_class.new
      result = user.name_and_login

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#full_name' do
    it 'full_name' do
      user = described_class.new
      result = user.full_name

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#has_role?' do
    it 'has_role?' do
      user = described_class.new
      result = user.has_role?([1,2])

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#does_not_have_role?' do
    it 'does_not_have_role?' do
      user = described_class.new
      result = user.does_not_have_role?([1,2])

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#add_role' do
    it 'add_role' do
      user = described_class.new
      result = user.add_role('1')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#remove_role' do
    it 'remove_role' do
      user = described_class.new
      role = double('role')
      result = user.remove_role(role)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#set_role_ids' do
    it 'set_role_ids' do
      user = described_class.new
      role_ids = [1,2]
      result = user.set_role_ids(role_ids)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#role_names' do
    let(:user) { FactoryBot.create(:user) }
    it 'role_names' do
      user.add_role('1')
      expect(user.role_names).to include '1'
    end
  end

  # TODO: auto-generated
  describe '#make_user_a_member' do
    let(:user) { FactoryBot.create(:user) }
    it 'make_user_a_member' do
      result = user.make_user_a_member
      expect(user.role_names).to include 'member'
    end
  end

  # TODO: auto-generated
  describe '#anonymous?' do
    it 'anonymous?' do
      user = described_class.new
      result = user.anonymous?

      expect(result).not_to be_nil
    end
  end

  describe '#is_project_admin?' do
    let(:user_role) { nil }
    let(:user_project) { nil }
    let(:user) {
      _user = FactoryBot.create(:user)
      if (user_role && user_project)
        _user.add_role_for_project(user_role, user_project)
      end
      _user
    }

    context 'when no project is passed in and user is' do
      subject { user.is_project_admin? }

      context 'not an admin of any projects' do
        it { is_expected.to be false}
      end

      context 'an admin of a project' do
        let(:user_role) { 'admin' }
        let(:user_project) { FactoryBot.create(:project) }
        it { is_expected.to be true}
      end

      context 'a researcher of a project' do
        let(:user_role) { 'researcher' }
        let(:user_project) { FactoryBot.create(:project) }
        it { is_expected.to be false}
      end

    end
    context 'when a project is passed in and user is' do
      let (:target_project) { FactoryBot.create(:project) }
      subject { user.is_project_admin?(target_project) }

      context 'not an admin of any projects' do
        it { is_expected.to be false}
      end

      context 'an admin of a different project' do
        let(:user_role) { 'admin' }
        let(:user_project) { FactoryBot.create(:project) }
        it { is_expected.to be false}
      end

      context 'an admin of the same project' do
        let(:user_role) { 'admin' }
        let(:user_project) { target_project }
        it { is_expected.to be true}
      end

      context 'a researcher of the same project' do
        let(:user_role) { 'researcher' }
        let(:user_project) { target_project }
        it { is_expected.to be false}
      end
    end
  end

  # TODO: auto-generated
  describe '#is_project_researcher?' do
    it 'is_project_researcher?' do
      user = described_class.new
      project = FactoryBot.create(:project)
      result = user.is_project_researcher?(project)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#is_project_cohort_member?' do
    it 'is_project_cohort_member?' do
      user = described_class.new
      project = FactoryBot.create(:project)
      result = user.is_project_cohort_member?(project)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#is_project_member?' do
    it 'is_project_member?' do
      user = described_class.new
      project = FactoryBot.create(:project)
      result = user.is_project_member?(project)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#add_role_for_project' do
    xit 'add_role_for_project' do
      user = described_class.new
      role = double('role')
      project = FactoryBot.create(:project)
      result = user.add_role_for_project(role, project)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#remove_role_for_project' do
    it 'remove_role_for_project' do
      user = described_class.new
      role = double('role')
      project = FactoryBot.create(:project)
      result = user.remove_role_for_project(role, project)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#set_role_for_projects' do
    it 'set_role_for_projects' do
      user = described_class.new
      role = double('role')
      possible_projects = []
      selected_project_ids = []
      result = user.set_role_for_projects(role, possible_projects, selected_project_ids)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.anonymous' do
    it 'anonymous' do
      reload = double('reload')
      result = described_class.anonymous(reload)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#school' do
    it 'school' do
      user = described_class.new
      result = user.school

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update_security_questions!' do
    it 'update_security_questions!' do
      user = described_class.new
      new_questions = double('new_questions')
      result = user.update_security_questions!(new_questions)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#updating_password?' do
    it 'updating_password?' do
      user = described_class.new
      result = user.updating_password?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#only_a_student?' do
    it 'only_a_student?' do
      user = described_class.new
      result = user.only_a_student?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#remember_me_for' do
    it 'remember_me_for' do
      user = described_class.new
      time = 2.days
      result = user.remember_me_for(time)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#remember_me_until' do
    it 'remember_me_until' do
      user = described_class.new
      time = Time.now
      result = user.remember_me_until(time)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#forget_me' do
    it 'forget_me' do
      user = described_class.new
      result = user.forget_me

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#set_passive_users_as_pending' do
    it 'set_passive_users_as_pending' do
      user = FactoryBot.create(:user)
      result = user.set_passive_users_as_pending

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#suspend!' do
    it 'suspend!' do
      user = described_class.new
      result = user.suspend!

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#delete!' do
    it 'delete!' do
      user = described_class.new
      result = user.delete!

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#unsuspend!' do
    it 'unsuspend!' do
      user = described_class.new
      result = user.unsuspend!

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#user_active?' do
    it 'user_active?' do
      user = described_class.new
      result = user.user_active?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.verified_imported_user?' do
    it 'verified_imported_user?' do
      login = 'login'
      result = described_class.verified_imported_user?(login)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#has_active_classes?' do
    it 'has_active_classes?' do
      user = described_class.new
      result = user.has_active_classes?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#has_portal_user_type?' do
    it 'has_portal_user_type?' do
      user = described_class.new
      result = user.has_portal_user_type?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#admin_for_project_cohorts' do
    it 'admin_for_project_cohorts' do
      user = described_class.new
      result = user.admin_for_project_cohorts

      expect(result).not_to be_nil
    end
  end

  describe '#admin_for_project_admins' do
    let (:project) { FactoryBot.create(:project) }
    let (:user) { FactoryBot.create(:user) }
    let (:project_admin) { FactoryBot.create(:user) }
    before(:each) do
      project_admin.add_role_for_project('admin', project)
    end

    it 'admin_for_project_admins' do
      result = user.admin_for_project_admins

      expect(result).not_to be_nil
    end
  end

  describe '#admin_for_project_researchers' do
    let (:project) { FactoryBot.create(:project) }
    let (:user) { FactoryBot.create(:user) }
    let (:project_researcher) { FactoryBot.create(:user) }
    before(:each) do
      project_researcher.add_role_for_project('researcher', project)
    end

    it 'admin_for_project_researchers' do
      result = user.admin_for_project_researchers

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#admin_for_project_teachers' do
    it 'admin_for_project_teachers' do
      user = described_class.new
      result = user.admin_for_project_teachers

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#admin_for_project_students' do
    it 'admin_for_project_students' do
      user = described_class.new
      result = user.admin_for_project_students

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#researcher_for_project_cohorts' do
    it 'researcher_for_project_cohorts' do
      user = described_class.new
      result = user.researcher_for_project_cohorts

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#researcher_for_project_teachers' do
    it 'researcher_for_project_teachers' do
      user = described_class.new
      result = user.researcher_for_project_teachers

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#researcher_for_project_students' do
    it 'researcher_for_project_students' do
      user = described_class.new
      result = user.researcher_for_project_students

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#cohorts' do
    it 'cohorts' do
      user = described_class.new
      result = user.cohorts

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#cohort_projects' do
    it 'cohort_projects' do
      user = described_class.new
      result = user.cohort_projects

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#projects' do
    it 'projects' do
      user = described_class.new
      result = user.projects

      expect(result).not_to be_nil
    end
  end

end
