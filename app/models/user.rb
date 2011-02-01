require 'digest/sha1'

class User < ActiveRecord::Base
  NO_EMAIL_STRING='no-email-'
  has_many :investigations
  has_many :resource_pages
  has_many :activities
  has_many :sections
  has_many :pages
  has_many :security_questions

  has_many :data_collectors, :class_name => 'Embeddable::DataCollector'
  has_many :xhtmls, :class_name => 'Embeddable::Xhtml'
  has_many :open_responses, :class_name => 'Embeddable::OpenResponse'
  has_many :multiple_choices, :class_name => 'Embeddable::MultipleChoice'
  has_many :data_tables, :class_name => 'Embeddable::DataTable'
  has_many :drawing_tools, :class_name => 'Embeddable::DrawingTool'
  has_many :mw_modeler_pages, :class_name => 'Embeddable::MwModelerPage'
  has_many :n_logo_models, :class_name => 'Embeddable::NLogoModel'

  named_scope :active, { :conditions => { :state => 'active' } }
  named_scope :no_email, { :conditions => "email LIKE '#{NO_EMAIL_STRING}%'" }
  named_scope :email, { :conditions => "email NOT LIKE '#{NO_EMAIL_STRING}%'" }
  named_scope :default, { :conditions => { :default_user => true } }
  named_scope :with_role, lambda { | role_name |
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

  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles

  attr_accessor :skip_notifications

  before_validation :strip_spaces

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

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :first_name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :first_name,     :maximum => 100

  validates_format_of       :last_name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :last_name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  validates_presence_of     :vendor_interface_id

  # Relationships
  has_and_belongs_to_many :roles, :uniq => true, :join_table => "roles_users"

  has_one :portal_teacher, :class_name => "Portal::Teacher"
  has_one :portal_student, :class_name => "Portal::Student"

  belongs_to :vendor_interface, :class_name => 'Probe::VendorInterface'

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
  default_value_for :vendor_interface_id, 6

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :first_name, :last_name, :password, :password_confirmation, :vendor_interface_id

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u1 = find_in_state :first, :active, :conditions => { :login => login } # need to get the salt
    u1 && u1.authenticated?(password) ? u1 : nil
  end

  def name
    _fullname = "#{first_name} #{last_name}".strip
    _fullname.empty? ? login : _fullname
  end

  def name_and_login
    _fullname = "#{first_name} #{last_name}".strip
    _fullname.empty? ? login : "#{_fullname} (#{login})"
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
    all_roles = Role.find(:all)
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
      anonymous_user = User.find_or_create_by_login(:login => "anonymous",
        :first_name => "Anonymous", :last_name => "User",
        :email => "anonymous@concord.org",
        :password => "password", :password_confirmation => "password"){|u| u.skip_notifications = true}
      anonymous_user.add_role('guest')
      @@anonymous_user = anonymous_user
    end
  end

  # a bit of a silly method to help the code in lib/changeable.rb so
  # it doesn't have to special-case findingthe owner of a user object
  def user
    self
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

  protected
  def make_activation_code
    self.deleted_at = nil
    self.activation_code = self.class.make_token
  end
end
