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
      assert_equal @user.state, 'pending'
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
     '', '1234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890',
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
    expect(User.authenticate('quentin', 'monkey')).not_to eq(users(:quentin))
  end

  it 'deletes user' do
    expect(users(:quentin).deleted_at).to be_nil
    users(:quentin).delete!
    expect(users(:quentin).deleted_at).not_to be_nil
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
    let(:project)     { FactoryGirl.create(:project) }
    let(:user)        { FactoryGirl.create(:user)    }

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
    let(:project)     { FactoryGirl.create(:project) }
    let(:user)        { FactoryGirl.create(:user)    }

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
    let(:projects)         { 5.times.map { |i|  FactoryGirl.create(:project, name: "project_#{i}")}  }
    let(:user)             { FactoryGirl.create(:user)    }
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


protected
  def create_user(options = {})
    record = User.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire69', :password_confirmation => 'quire69' }.merge(options))
    record.save! if record.valid?
    record
  end
end
