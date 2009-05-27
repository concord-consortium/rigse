require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles

  # Validations
  
  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  # validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  # validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  validates_presence_of     :vendor_interface_id

  # Relationships
  has_and_belongs_to_many :roles
  has_many :activities
  has_many :sections
  has_many :pages
  
  has_many :data_collectors
  has_many :xhtmls
  has_many :open_responses
  has_many :multiple_choices
  has_many :data_tables
  has_many :drawing_tools
  
  belongs_to :vendor_interface

  has_many :assessment_targets
  has_many :big_ideas
  has_many :domains
  has_many :expectations
  has_many :expectation_stems
  has_many :grade_span_expectations
  has_many :knowledge_statements
  has_many :unifying_themes

  acts_as_replicatable

  include Changeable
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{login first_name last_name email}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  

  # we will lazy load the anonymous user later
  @@anonymous_user = nil 
 
  # we need a default VendorInterface, 6 = Vernier Go! IO
  default_value_for :vendor_interface_id, 6

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :first_name, :last_name, :password, :password_confirmation, :identity_url

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u1 = find_in_state :first, :active, :conditions => { :login => login } # need to get the salt
    u1 && u1.authenticated?(password) ? u1 : nil
  end
  
  def name
    _fullname = "#{first_name} #{last_name}"
    _fullname.strip != "" ? _fullname : login
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
    (roles.map{ |r| r.title.downcase } & role_list.flatten).length > 0
  end

  def does_not_have_role?(*role_list)
    !has_role?(role_list)
  end

  def make_user_a_member
    roles << Role.find_by_title('member')
  end

  # return the user who is the site administrator
  def self.site_admin
    User.find_by_email(APP_CONFIG[:admin_email])
  end
  
  # is this user the anonymous user?
  def anonymous?
    self == User.anonymous
  end
  
  # class method for returning the anonymous user
  def self.anonymous
    @@anonymous_user ||=  User.find_by_login('anonymous')
  end

  protected
    
  def make_activation_code
    self.deleted_at = nil
    self.activation_code = self.class.make_token
  end
end
