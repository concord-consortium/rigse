require 'digest/sha1'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  has_many :authentications, :dependent => :delete_all
  has_many :access_grants, :dependent => :delete_all


  devise :database_authenticatable, :registerable,:token_authenticatable, :confirmable, :bearer_token_authenticatable,
         :recoverable,:timeoutable, :rememberable, :trackable, :validatable,:encryptable, :encryptor => :restful_authentication_sha1
  devise :omniauthable, :omniauth_providers => [:schoology]
  self.token_authentication_key = "access_token"
  default_scope where(User.arel_table[:state].not_in(['disabled']))

  def apply_omniauth(omniauth)
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  # scytacki: This code should be revised because the access_grant should not be trusted if
  #  access_token_expires_at is NULL. It should only be trusted once it has been requested
  #  by a Client that has verified its ID and SECRET.
  #  I'm not fixing this now (Jan 30, 2015) because we are about
  #  to do a release and we don't have time to fully test this change
  def self.find_for_token_authentication(conditions)
    where(["access_grants.access_token = ? AND (access_grants.access_token_expires_at IS NULL OR access_grants.access_token_expires_at > ?)", conditions[token_authentication_key], Time.now]).joins(:access_grants).select("users.*").first
  end

  NO_EMAIL_STRING='no-email-'
  has_many :investigations
  has_many :resource_pages
  has_many :activities
  has_many :interactives
  has_many :sections
  has_many :pages
  has_many :external_activities
  has_many :security_questions

  has_many :data_collectors, :class_name => 'Embeddable::DataCollector'
  has_many :xhtmls, :class_name => 'Embeddable::Xhtml'
  has_many :open_responses, :class_name => 'Embeddable::OpenResponse'
  has_many :multiple_choices, :class_name => 'Embeddable::MultipleChoice'
  has_many :data_tables, :class_name => 'Embeddable::DataTable'
  has_many :drawing_tools, :class_name => 'Embeddable::DrawingTool'
  has_many :mw_modeler_pages, :class_name => 'Embeddable::MwModelerPage'
  has_many :n_logo_models, :class_name => 'Embeddable::NLogoModel'

  has_many :created_notices, :dependent => :destroy, :class_name => 'Admin::SiteNotice', :foreign_key => 'created_by'
  has_many :updated_notices, :dependent => :destroy, :class_name => 'Admin::SiteNotice', :foreign_key => 'updated_by'

  has_many :project_users, class_name: 'Admin::ProjectUser'
  has_many :projects, :through => :project_users

  has_one :notice_user_display_status, :dependent => :destroy ,:class_name => "Admin::NoticeUserDisplayStatus", :foreign_key => "user_id"

  scope :all_users, { :conditions => {}}
  scope :active, { :conditions => { :state => 'active' } }
  scope :suspended, {:conditions => { :state => 'suspended'}}
  scope :no_email, { :conditions => "email LIKE '#{NO_EMAIL_STRING}%'" }
  scope :email, { :conditions => "email NOT LIKE '#{NO_EMAIL_STRING}%'" }
  scope :default, { :conditions => { :default_user => true } }
  scope :with_role, lambda { | role_name |
    { :include => :roles, :conditions => ['roles.title = ?',role_name]}
  }
  has_settings

  # has_many :assessment_targets, :class_name => 'RiGse::AssessmentTarget'
  # has_many :big_ideas, :class_name => 'RiGse::BigIdea'
  # has_many :domains, :class_name => 'RiGse::Domain'
  # has_many :expectations, :class_name => 'RiGse::Expectation'
  # has_many :expectation_stems, :class_name => 'RiGse::ExpectationStem'
  # has_many :grade_span_expectations, :class_name => 'RiGse::GradeSpanExpectation'
  # has_many :knowledge_statements, :class_name => 'RiGse::KnowledgeStatement'
  # has_many :unifying_themes, :class_name => 'RiGse::UnifyingTheme'

  include Changeable

  attr_accessor :skip_notifications

  before_validation :strip_spaces

  after_update :set_passive_users_as_pending
  after_create :set_passive_users_as_pending
  after_create :add_to_default_project

  # strip leading and trailing spaces from names, login and email
  def strip_spaces
    # these are conditionalized because it is called before the validation
    # so the validation will make sure they are setup correctly
    self.first_name? && self.first_name.strip!
    self.last_name? && self.last_name.strip!
    self.login? && self.login.strip!
    self.email? && self.email.strip!
    self
  end

  # Validations

  login_regex       = /\A\w[\w\.\-_@]+\z/                     # ASCII, strict
  bad_login_message = "use only letters, numbers, and .-_@ please.".freeze

  name_regex        = /\A[^[:cntrl:]\\<>\/&]*\z/              # Unicode, permissive
  bad_name_message  = "avoid non-printing characters and \\&gt;&lt;&amp;/ please.".freeze

  email_name_regex  = '[\w\.%\+\-\']+'.freeze
  domain_head_regex = '(?:[A-Z0-9\-]+\.)+'.freeze
  domain_tld_regex  = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'.freeze
  email_regex       = /\A#{email_name_regex}@#{domain_head_regex}#{domain_tld_regex}\z/i
  bad_email_message = "should look like an email address.".freeze



  validates_presence_of     :login
  validates_length_of       :login,    :within => 1..40
  validates_uniqueness_of   :login, :case_sensitive => false
  validates_format_of       :login,    :with => login_regex, :message => bad_login_message

  validates_format_of       :first_name,     :with => name_regex,  :message => bad_name_message, :allow_nil => true
  validates_length_of       :first_name,     :maximum => 100

  validates_format_of       :last_name,     :with => name_regex,  :message => bad_name_message, :allow_nil => true
  validates_length_of       :last_name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_format_of       :email,    :with => email_regex, :message => bad_email_message

  validates_presence_of     :vendor_interface_id
  validates_presence_of     :password, :on => :update, :if => :updating_password?
  validates_presence_of     :password_confirmation, :on => :create
  validates_presence_of     :password_confirmation, :on => :update, :if => :updating_password?
  validates_confirmation_of :password_confirmation

  # Relationships
  has_and_belongs_to_many :roles, :uniq => true, :join_table => "roles_users"

  has_one :portal_teacher, :dependent => :destroy, :class_name => "Portal::Teacher", :inverse_of => :user
  has_one :portal_student, :dependent => :destroy, :class_name => "Portal::Student", :inverse_of => :user

  belongs_to :vendor_interface, :class_name => 'Probe::VendorInterface'

  attr_accessor :updating_password

  acts_as_replicatable

  self.extend SearchableModel

  @@searchable_attributes = %w{login first_name last_name email}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

    def login_exists?(login)
      User.count(:conditions => "`login` = '#{login}'") >= 1
    end

    def login_does_not_exist?(login)
      User.count(:conditions => "`login` = '#{login}'") == 0
    end

    def suggest_login(first,last)
      base = "#{first.first}#{last}".downcase.gsub(/[^a-z]/, "_")
      suggestion = base
      count = 0
      while(login_exists?(suggestion))
        count = count + 1
        suggestion = "#{base}#{count}"
      end
      return suggestion
    end

    def default_users
      User.find(:all, :conditions => { :default_user => true })
    end

    def suspend_default_users
      default_users.each { |user| user.suspend! if user.state == 'active' }
    end

    def unsuspend_default_users
      default_users.each { |user| user.unsuspend! if user.state == 'suspended' }
    end

    # return the user who is the site administrator
    def site_admin
      User.find_by_email(APP_CONFIG[:default_admin_user][:email])
    end

    def find_for_omniauth(auth, signed_in_resource=nil)
      authentication = Authentication.find_by_provider_and_uid auth.provider, auth.uid
      if authentication
        # Since we're not planning to access the provider on behalf of the user,
        # don't bother storing tokens for now.
        # update the authentication token for this user to make sure it stays fresh
        # authentication.update_attribute(:token, auth.credentials.token)
        return authentication.user
      end

      # there is no authentication for this provider and uid
      # see if we should create a new authentication for an existing user
      # or make a whole new user
      email = auth.info.email || "#{Devise.friendly_token[0,20]}@example.com"

      # the devise validatable model enforces unique emails, so no need find_all
      existing_user_by_email = User.find_by_email email

      if existing_user_by_email
        if existing_user_by_email.authentications.find_by_provider auth.provider
          throw "Can't have duplicate email addresses: #{email}. " +
                "There is an user with an authentication for this provider #{auth.provider} " +
                "and the same email already."
        end
        # There is no authentication for this provider and user
        user = existing_user_by_email
      else
        # no user with this email, so make a new user with a random password
        user = User.create(
          email:    email,
          password: User.get_random_password
        )
      end
      # create new authentication for this user that we found or created
      user.authentications.create(
        provider: auth.provider,
        uid:      auth.uid
        # token:    auth.credentials.token
      )
      user
    end
  end

  def removed_investigation
    unless self.has_investigations?
      self.remove_role('author')
    end
  end

  def has_investigations?
    investigations.length > 0
  end

  # we will lazy load the anonymous user later
  @@anonymous_user = nil

  # default users are a class of users that can be enable
  default_value_for :default_user, false

  # we need a default Probe::VendorInterface, 6 = Vernier Go! IO
  default_value_for :vendor_interface_id, 14

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :first_name, :last_name, :password, :password_confirmation, :remember_me,
                  :vendor_interface_id, :external_id, :of_consenting_age, :have_consent,:confirmation_token,:confirmed_at,:state

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u1 =  User.find(:first, :conditions => ['login = ? AND state = "active"',login])
    u1 && u1.valid_password?(password) ? u1 : nil
  end

  # Creates a new access token valid for given time.
  def create_access_token_valid_for(time)
    return access_grants.create!(access_token_expires_at: time.from_now + 1.second).access_token
  end

  def active_for_authentication?
    super && user_active?
  end

  def confirm!
    super
    self.state = "active"
    save(:validate => true)
    self.make_user_a_member
  end

  def inactive_message
    user_active? ? super : "You cannot login since your account has been suspended."
  end

  def name
    _fullname = "#{first_name} #{last_name}".strip
    _fullname.empty? ? login : _fullname
  end

  def name_and_login
    _fullname = "#{last_name}, #{first_name}".strip
    _fullname.empty? ? login : "#{_fullname} ( #{login} )"
  end

  def full_name
    _fullname = "#{last_name}, #{first_name}".strip
    _fullname.empty? ? login : "#{_fullname}"
  end

  # Check if a user has a role.
  #
  # Returns True if User has one of the roles.
  # False otherwize.
  #
  # You can pass in a sequence of strings:
  #
  #  user.has_role?("admin", "manager")
  #
  # or an array of strings:
  #
  #  user.has_role?(%w{admin manager})
  #
  def has_role?(*role_list)
    roles.reload # will always hit the database?
    (roles.map{ |r| r.title.downcase } & role_list.flatten).length > 0
  end

  def does_not_have_role?(*role_list)
    !has_role?(role_list)
  end

  def add_role(role)
    unless has_role?(role)
      roles << Role.find_or_create_by_title(role)
    end
  end

  def remove_role(role)
    if has_role?(role)
      roles.delete Role.find_by_title(role)
    end
  end

  def set_role_ids(role_ids)
    all_roles = Role.all
    all_roles.each do |role|
      if role_ids.find { |id| id.to_i == role.id }
        add_role(role.title)
      else
        remove_role(role.title)
      end
    end
  end

  def make_user_a_member
    self.add_role('member')
  end

  # is this user the anonymous user?
  def anonymous?
    self == User.anonymous
  end

  def set_project_ids(project_ids)
    all_projects = Admin::Project.all
    all_projects.each do |project|
      if project_ids.find { |id| id.to_i == project.id }
        projects << project if !projects.include? project
      else
        projects.delete project
      end
    end
  end

  # Class method for returning the memoized anonymous user
  #
  # If you have deleted and recreated the Anonymous user
  # then call User.anonymous(true) once to reload the memoized
  # object. If you don't then calling User.anonymous will return
  # the older deleted Anonymous user.
  #
  # If the anonymous user can't be found it is created.
  #
  # FIXME: using class variables like this is not thread-safe
  #
  def self.anonymous(reload=false)
    @@anonymous_user = nil if reload
    if @@anonymous_user
      @@anonymous_user
    else
      anonymous_user = User.find_or_create_by_login(
        :login                 => "anonymous",
        :first_name            => "Anonymous",
        :last_name             => "User",
        :email                 => "anonymous@concord.org",
        :password              => "password",
        :password_confirmation => "password"){|u| u.skip_notifications = true}
      anonymous_user.add_role('guest')
      @@anonymous_user = anonymous_user
    end
  end

  # a bit of a silly method to help the code in lib/changeable.rb so
  # it doesn't have to special-case findingthe owner of a user object
  def user
    self
  end

  # If this user is a student, allow the student's teacher(s) to make
  # changes to this.
  def is_user?(user)
    if user == self
      true
    elsif user.portal_teacher && self.portal_student && self.portal_student.has_teacher?(user.portal_teacher)
      true
    else
      false
    end
  end

  def school
    school_person = self.portal_teacher || self.portal_student
    if (school_person)
      return school_person.school
    end
  end

  def extra_params
    if self.school
      params = school.settings_hash
    end
    if params
      return params.merge(self.settings_hash)
    end
    return self.settings_hash
  end

  # This method gets a bang because it saves the new questions. -- Cantina-CMH 6/17/10
  def update_security_questions!(new_questions)
    return unless new_questions.is_a?(Array)

    self.security_questions.destroy_all

    new_questions.each do |q|
      self.security_questions << q
      q.save
    end
  end

  def updating_password?
    updating_password
  end

  def only_a_student?
    portal_student and !has_role?('admin', 'manager', 'researcher', 'author') and portal_teacher.nil?
  end

  def remember_me_for(time)
    self.remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_created_at = time
    self.remember_token = self.class.remember_token
    save(:validate => false)
  end

  def forget_me
    self.forget_me!
  end

  def set_passive_users_as_pending
    if (self.state == 'passive' && (!self.confirmation_token.nil? && self.confirmed_at.nil?))
      self.update_attribute(:state, "pending")
    end
    self.reload
  end

  def add_to_default_project
    default_project = Admin::Settings.default_settings && Admin::Settings.default_settings.default_project
    if default_project
      self.projects << default_project
    end
  end

  def suspend!
    self.update_attribute(:state, 'suspended')
    self.reload
  end

  def delete!
    self.update_attribute(:state, 'disabled')
    self.update_attribute( :deleted_at, DateTime.now.utc)
    self.reload
  end

  def unsuspend!
    user_state = "active"
    user_state = (self.confirmation_token.nil? && self.confirmed_at.nil?)? "passive" : user_state
    user_state = (!self.confirmation_token.nil? && self.confirmed_at.nil?)? "pending" : user_state
    self.update_attribute(:state, user_state)
    self.reload
  end

  def user_active?
    self.state != "suspended" && self.state != "disabled"
  end

  protected
  def make_activation_code
    self.deleted_at = nil
    self.activation_code = self.class.make_token
  end

end
