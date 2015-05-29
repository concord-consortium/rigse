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
      @creating_user.should change(User, :count).by(1)
    end

    it 'initializes #activation_code' do
      @creating_user.call
      @user.reload
      @user.confirmation_token.should_not be_nil
    end

    it 'starts in pending state' do
      @creating_user.call
      @user.reload
      assert_equal @user.state, 'pending'
    end

    describe '[default project support]' do
      let(:settings) { Factory.create(:admin_settings) }
      before(:each) do
        Admin::Settings.stub!(:default_settings).and_return(settings)
      end

      describe 'when default project is not specified in portal settings' do
        it 'has empty list of projects' do
          @creating_user.call
          expect(@user.projects.length).to eql(0)
        end
      end

      describe 'when default project is specified in portal settings' do
        let(:project) { Factory.create(:project) }
        let(:settings) { Factory.create(:admin_settings, default_project: project) }

        it 'is added to the default project' do
          @creating_user.call
          expect(@user.projects.length).to eql(1)
          expect(@user.projects[0]).to eql(project)
        end
      end
    end
  end

  #
  # Validations
  #

  it 'requires login' do
    lambda do
      u = create_user(:login => nil)
      u.errors[:login].should_not be_nil
    end.should_not change(User, :count)
  end

  describe 'allows legitimate logins:' do
    ['123', '1234567890_234567890_234567890_234567890',
     'hello.-_there@funnychar.com'].each do |login_str|
      it "'#{login_str}'" do
        lambda do
          u = create_user(:login => login_str)
          u.errors[:login].should == []
        end.should change(User, :count).by(1)
      end
    end
  end

  describe 'disallows illegitimate logins:' do
    ['', '1234567890_234567890_234567890_234567890_',
     "Iñtërnâtiônàlizætiøn hasn't happened to ruby 1.8 yet",
     'semicolon;', 'quote"', 'backtick`', 'percent%', 'plus+'].each do |login_str|
      it "'#{login_str}'" do
        lambda do
          u = create_user(:login => login_str)
          u.errors[:login].should_not be_nil
        end.should_not change(User, :count)
      end
    end
  end

  it 'requires password' do
    lambda do
      u = create_user(:password => nil)
      u.errors[:password].should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires password confirmation' do
    lambda do
      u = create_user(:password_confirmation => nil)
      u.errors[:password_confirmation].should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires email' do
    lambda do
      u = create_user(:email => nil)
      u.errors[:email].should_not be_nil
    end.should_not change(User, :count)
  end

  describe 'allows legitimate emails:' do
    ['foo@bar.com', 'foo@newskool-tld.museum', 'foo@twoletter-tld.de', 'foo@nonexistant-tld.qq',
     'r@a.wk', '1234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890@gmail.com',
     'hello.-_there@funnychar.com', 'uucp%addr@gmail.com', 'hello+routing-str@gmail.com',
     'domain@can.haz.many.sub.doma.in', 'student.name@university.edu'
    ].each do |email_str|
      it "'#{email_str}'" do
        lambda do
          u = create_user(:email => email_str)
          u.errors[:email].should == []
        end.should change(User, :count).by(1)
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
        lambda do
          u = create_user(:email => email_str)
          u.errors[:email].should_not be_nil
        end.should_not change(User, :count)
      end
    end
  end

  describe 'allows legitimate names:' do
    ['Andre The Giant (7\'4", 520 lb.) -- has a posse',
     '', '1234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890',
    ].each do |name_str|
      it "'#{name_str}'" do
        lambda do
          u = create_user(:first_name => name_str)
          u.errors[:first_name].should == []
        end.should change(User, :count).by(1)
      end
    end
  end
  describe "disallows illegitimate names" do
    ['1234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_',
     ].each do |name_str|
      it "'#{name_str}'" do
        lambda do
          u = create_user(:first_name => name_str)
          u.errors[:first_name].should_not be_nil
        end.should_not change(User, :count)
      end
    end
  end

  it 'resets password' do
    users(:quentin).update_attributes({:password => 'new password', :password_confirmation => 'new password'})
    User.authenticate('quentin', 'new password').should == users(:quentin)
  end

  it 'does not rehash password' do
    users(:quentin).update_attributes({:login => 'quentin2'})
    User.authenticate('quentin2', 'monkey').should == users(:quentin)
  end

  #
  # Authentication
  #

  it 'authenticates user' do
    User.authenticate('quentin', 'monkey').should == users(:quentin)
  end

  it "doesn't authenticate user with bad password" do
    User.authenticate('quentin', 'invalid_password').should be_nil
  end

 if REST_AUTH_SITE_KEY.blank?
   # old-school passwords
   it "authenticates a user against a hard-coded old-style password" do
     User.authenticate('old_password_holder', 'monkey').should == users(:old_password_holder)
   end
 else
   it "doesn't authenticate a user against a hard-coded old-style password" do
     User.authenticate('old_password_holder', 'monkey').should be_nil
   end

   # New installs should bump this up and set REST_AUTH_DIGEST_STRETCHES to give a 10ms encrypt time or so
   desired_encryption_expensiveness_ms = 0.1
   it "takes longer than #{desired_encryption_expensiveness_ms}ms to encrypt a password" do
     test_reps = 100
     start_time = Time.now; test_reps.times{ User.authenticate('quentin', 'monkey'+rand.to_s) }; end_time   = Time.now
     auth_time_ms = 1000 * (end_time - start_time)/test_reps
     auth_time_ms.should > desired_encryption_expensiveness_ms
   end
 end

  #
  # Authentication
  #

  it 'sets remember token' do
    users(:quentin).remember_me!
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_created_at.should_not be_nil
  end

  it 'unsets remember token' do
    users(:quentin).remember_me!
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).forget_me
    users(:quentin).remember_token.should be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.ago.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_created_at.should_not be_nil
    users(:quentin).remember_created_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_created_at.should_not be_nil
    users(:quentin).remember_created_at.utc.to_s(:db).should == time.to_s(:db)
  end

  it 'remembers me default two weeks' do
    before = 2.weeks.ago.utc
    users(:quentin).remember_me!
    after = 2.weeks.from_now.utc
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_created_at.should_not be_nil
    users(:quentin).remember_created_at.between?(before, after).should be_true
  end

  it 'registers passive user' do
    user = create_user(:password => nil, :password_confirmation => nil)
    assert_equal user.state, 'passive'
    user.update_attributes({:password => 'new password', :password_confirmation => 'new password'})
    user.save!
    user.reload
    assert_equal user.state, 'pending'
  end

  it 'suspends user' do
    users(:quentin).suspend!
    assert_equal users(:quentin).state, 'suspended'
  end

  it 'does not authenticate suspended user' do
    users(:quentin).suspend!
    User.authenticate('quentin', 'monkey').should_not == users(:quentin)
  end

  it 'deletes user' do
    users(:quentin).deleted_at.should be_nil
    users(:quentin).delete!
    users(:quentin).deleted_at.should_not be_nil
    assert_equal users(:quentin).state, 'disabled'
  end

  describe "being unsuspended" do
    fixtures :users

    before do
      @user = users(:quentin)
      @user.suspend!
    end

    it 'reverts to active state' do
      @user.unsuspend!
      assert_equal @user.state, 'active'
    end

    it 'reverts to passive state if activation_code and activated_at are nil' do
      User.update_all({:confirmation_token => nil, :confirmed_at => nil})
      @user.reload.unsuspend!
      assert_equal @user.state, 'passive'
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
      assert_equal @user.state, 'pending'
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

      @user.security_questions.should be_empty

      @user.update_security_questions!(questions)

      @user.security_questions.size.should == 3
      questions.each do |v|
        @user.security_questions.select { |q| q.question == v.question && q.answer == v.answer }.size.should == 1
      end
    end
  end

  describe "checking for logins" do
    describe "when available" do
      before(:each) do
        User.should_receive(:login_exists?).with("hpotter").and_return(false)
      end
      it "should return the first initial and last name" do
        User.suggest_login('Harry','Potter').should == "hpotter"
      end
    end
    describe "when not available" do
      it "should append a counter number to the default login" do
        User.should_receive(:login_exists?).once.with("hpotter").ordered.and_return(true)
        User.should_receive(:login_exists?).once.with("hpotter1").ordered.and_return(true)
        User.should_receive(:login_exists?).once.with("hpotter2").ordered.and_return(true)
        User.should_receive(:login_exists?).once.with("hpotter3").ordered.and_return(false)
        User.suggest_login('Harry','Potter').should == "hpotter3"
      end
    end
  end

  describe "require_reset_password" do
    before(:each) do
      @user = create_user(:login => 'default_user', :email => 'nobody@noplace.com')
    end
    describe "freshly minted user" do
      it "will not require the password to be reset" do
        @user.require_password_reset.should be_false
      end
    end
  end

protected
  def create_user(options = {})
    record = User.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire69', :password_confirmation => 'quire69' }.merge(options))
    record.save! if record.valid?
    record
  end
end
