require 'digest/sha1'

class User < ActiveRecord::Base
  NO_EMAIL_STRING='no-email-'
  has_many :investigations
  has_many :activities
  has_many :sections
  has_many :pages
  
  has_many :data_collectors
  has_many :xhtmls
  has_many :open_responses
  has_many :multiple_choices
  has_many :data_tables
  has_many :drawing_tools
  has_many :mw_modeler_pages
  has_many :n_logo_models

  named_scope :active, { :conditions => { :state => 'active' } }  
  named_scope :no_email, { :conditions => "email LIKE '#{NO_EMAIL_STRING}%'" }
  named_scope :email, { :conditions => "email NOT LIKE '#{NO_EMAIL_STRING}%'" }
  named_scope :default, { :conditions => { :default_user => true } }
  
  # has_many :assessment_targets
  # has_many :big_ideas
  # has_many :domains
  # has_many :expectations
  # has_many :expectation_stems
  # has_many :grade_span_expectations
  # has_many :knowledge_statements
  # has_many :unifying_themes
  
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
  
  belongs_to :vendor_interface

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
      User.find_by_email(APP_CONFIG[:default_admin_user]['email'])
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
 
  # we need a default VendorInterface, 6 = Vernier Go! IO
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
    roles.reload
    (roles.map{ |r| r.title.downcase } & role_list.flatten).length > 0
  end

  def does_not_have_role?(*role_list)
    !has_role?(role_list)
  end

  def add_role(role)
    unless has_role?(role)
      roles << Role.find_by_title(role)
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
    roles << Role.find_by_title('member')
  end
  
  # is this user the anonymous user?
  def anonymous?
    self == User.anonymous
  end
  
  # class method for returning the anonymous user
  def self.anonymous
    @@anonymous_user ||=  @@anonymous_user = User.find_by_login('anonymous')
  end

  # a bit of a silly method to help the code in lib/changeable.rb so
  # it doesn't have to special-case findingthe owner of a user object
  def user
    self
  end

  protected
    
  def make_activation_code
    self.deleted_at = nil
    self.activation_code = self.class.make_token
  end
end
