require 'digest/sha1'

class User < ApplicationRecord
  has_many :authentications, :dependent => :delete_all
  has_many :access_grants, :dependent => :delete_all

  has_many :favorites

  devise :database_authenticatable, :registerable, :token_authenticatable, :confirmable, :bearer_token_authenticatable, :jwt_bearer_token_authenticatable,
         :recoverable, :timeoutable, :trackable, :validatable,:encryptable, :encryptor => :restful_authentication_sha1
  devise :omniauthable, :omniauth_providers => Devise.omniauth_providers

  def apply_omniauth(omniauth)
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  # scytacki: This code should be revised because the access_grant should not be trusted if
  #  access_token_expires_at is NULL. It should only be trusted once it has been requested
  #  by a Client that has verified its ID and SECRET.
  #  I'm not fixing this now (Jan 30, 2015) because we are about
  #  to do a release and we don't have time to fully test this change
  def self.find_for_token_authentication(conditions)
    where(["access_grants.access_token = ? AND (access_grants.access_token_expires_at IS NULL OR access_grants.access_token_expires_at > ?)", conditions[:access_token], Time.now]).joins(:access_grants).select("users.*").first
  end

  NO_EMAIL_STRING = 'no-email-'
  NO_EMAIL_DOMAIN = 'concord.org'

  has_many :interactives
  has_many :external_activities
  has_many :security_questions

  belongs_to :primary_account, :class_name => "User", :optional => true
  has_many :secondary_accounts, :class_name => "User", :foreign_key => "primary_account_id"

  has_one :portal_teacher, :dependent => :destroy, :class_name => "Portal::Teacher", :inverse_of => :user
  has_one :portal_student, :dependent => :destroy, :class_name => "Portal::Student", :inverse_of => :user

  has_many :created_notices, :dependent => :destroy, :class_name => 'Admin::SiteNotice', :foreign_key => 'created_by'
  has_many :updated_notices, :dependent => :destroy, :class_name => 'Admin::SiteNotice', :foreign_key => 'updated_by'

  has_many :teacher_cohorts, :through => :portal_teacher, :source => :cohorts
  has_many :teacher_cohort_projects, :through => :portal_teacher, :source => :projects
  has_many :student_cohorts, :through => :portal_student, :source => :cohorts
  has_many :student_cohort_projects, :through => :portal_student, :source => :projects

  has_many :project_users, class_name: 'Admin::ProjectUser', :dependent => :destroy

  has_many :_project_user_admins, -> { is_admin }, :class_name => 'Admin::ProjectUser'

  has_many :_project_user_researchers, -> { is_researcher.where("expiration_date IS NULL OR expiration_date > ?", Date.today) }, class_name: 'Admin::ProjectUser'
  has_many :_project_user_researchers_inc_expired, -> { is_researcher }, class_name: 'Admin::ProjectUser'

  has_many :admin_for_projects, :through => :_project_user_admins, :class_name => 'Admin::Project', :source => :project

  has_many :researcher_for_projects, :through => :_project_user_researchers, :class_name => 'Admin::Project', :source => :project
  has_many :researcher_for_projects_inc_expired, :through => :_project_user_researchers_inc_expired, :class_name => 'Admin::Project', :source => :project

  # has_many :researcher_for_projects, -> { where is_researcher: true }, :through => :project_users, :class_name => 'Admin::Project', :source => :project

  has_one :notice_user_display_status, :dependent => :destroy ,:class_name => "Admin::NoticeUserDisplayStatus", :foreign_key => "user_id"

  default_scope -> { where.not(state: 'disabled') }
  scope :all_users, -> { where(nil) }
  scope :active, -> { where(state: 'active') }
  scope :suspended, -> { where(state: 'suspended') }
  scope :no_email, -> { where("email LIKE '#{NO_EMAIL_STRING}%'") }
  scope :email, -> { where("email NOT LIKE '#{NO_EMAIL_STRING}%'") }
  # NB: This name is unfortunate, it is too similar to default_scope!
  # Though the names are similar this scope searches for `default` users.
  scope :default, -> { where(default_user: true) }
  scope :with_role, lambda { | role_name |
    where('roles.title = ?',role_name).includes(:roles).references(:roles)
  }

  attr_accessor :skip_notifications

  before_validation :strip_spaces

  after_update :set_passive_users_as_pending
  after_create :set_passive_users_as_pending

  def self.per_page
    # number of results to show in admin/users (default is 30)
    10
  end

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

  @@login_regex     = /\A[\p{L}\d][\p{L}\d\.\-\+_@]+\z/ # ASCII and unicode
  bad_login_message = "use only letters, numbers, and +.-_@ please.".freeze

  def self.login_regex
    @@login_regex
  end

  #
  # name_regex      Lookahead regex. Between start and end of word, match
  #                 none of the control or special characters listed.
  #                 The second paren group says at least one of what was
  #                 previously matched must be a letter character or digit.
  #
  @@name_regex      = /(?=\A[^[:cntrl:]\\<>\/&]*\z)(.*[\p{L}\d].*)/u

  #
  # User friendly representation of restricted name characters
  #
  @@restricted_characters = "\\, <, >, &, /"

  bad_name_message  = I18n.t(   'UserBadName',
                                restricted_characters: @@restricted_characters )

  def self.name_regex
    @@name_regex
  end

  email_name_regex  = '[\w\.%\+\-\']+'.freeze
  domain_head_regex = '(?:[A-Z0-9\-]+\.)+'.freeze
  domain_tld_regex  = '(?:[A-Z]{2,})'.freeze
  email_regex       = /\A#{email_name_regex}@#{domain_head_regex}#{domain_tld_regex}\z/i
  bad_email_message = "should look like an email address.".freeze



  validates_presence_of     :login
  validates_length_of       :login,    :within => 1..40
  validates_uniqueness_of   :login, :case_sensitive => false
  validates_format_of       :login,    :with => @@login_regex, :message => bad_login_message

  validates_format_of       :first_name,     :with => @@name_regex,  :message => bad_name_message, :allow_nil => false
  validates_length_of       :first_name,     :maximum => 100

  validates_format_of       :last_name,     :with => @@name_regex,  :message => bad_name_message, :allow_nil => false
  validates_length_of       :last_name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_format_of       :email,    :with => email_regex, :message => bad_email_message

  validates_presence_of     :password, :on => :update, :if => :updating_password?
  validates_presence_of     :password_confirmation, :on => :create
  validates_presence_of     :password_confirmation, :on => :update, :if => :updating_password?
  validates_confirmation_of :password_confirmation

  # Relationships
  has_and_belongs_to_many :roles, -> { distinct }, :join_table => "roles_users"


  has_one :imported_user, :dependent => :destroy, :class_name => "Import::ImportedUser", :inverse_of => :user

  attr_accessor :updating_password

  acts_as_replicatable

  self.extend SearchableModel

  @@searchable_attributes = %w{login first_name last_name email}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

    def login_exists?(login)
      User.where("`login` = '#{login}'").count >= 1
    end

    def login_does_not_exist?(login)
      User.where("`login` = '#{login}'").count == 0
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
      User.where(:default_user => true)
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

      #
      # Check for an existing user with this email.
      # the devise validatable model enforces unique emails, so no need find_all
      #
      existing_user_by_email = User.find_by_email auth.info.email

      if existing_user_by_email
        user = existing_user_by_email

        #
        # Check if this is a student. This shouldn't be the case if we have
        # an email stored.
        #
        if user.portal_student
          raise "Error: found portal student with persisted email from #{auth.provider}."
        end

      else
        #
        # no user with this email, so make a new user with a random password
        # if a teacher finishes the registration this generated email will be replaced
        # with the real email from the provider. If a student finishes the registration
        # the generate email will remain.
        #
        login = auth.provider + "-" + auth.uid
        email = NO_EMAIL_STRING + login + '@' + NO_EMAIL_DOMAIN
        pw = Devise.friendly_token.first(12)

        user = User.create!(
          login:        login,
          email:        email,
          # Some schools are leaving their students first or last names blank.
          # The portal and reports assume a student has both names, so we are using
          # Unknown in this case.
          # In the future we might want to change our systems to support the case of a
          # blank name.
          first_name:   auth.extra.first_name   || auth.info.first_name || 'Unknown',
          last_name:    auth.extra.last_name    || auth.info.last_name || 'Unknown',
          password: pw,
          password_confirmation: pw,
          skip_notifications: true
        )
        user.confirm
      end

      #
      # Create new authentication for this user that we found or created
      # if one does not exist.
      #
      if ! user.authentications.find_by_provider auth.provider
        user.authentications.create(
          provider: auth.provider,
          uid:      auth.uid
          # token:    auth.credentials.token
        )
      end

      user
    end
  end

  # we will lazy load the anonymous user later
  @@anonymous_user = nil

  # default users are a class of users that can be enable
  default_value_for :default_user, false

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u1 =  User.where('login = ? AND state = "active"',login).first
    u1 && u1.valid_password?(password) ? u1 : nil
  end

  # Creates a new access token valid for given time.
  def create_access_token_valid_for(time)
    return access_grants.create!(access_token_expires_at: time.from_now + 1.second).access_token
  end

  # Creates a new access token valid for given time with an associated learner.
  def create_access_token_with_learner_valid_for(time, learner)
    return access_grants.create!(access_token_expires_at: time.from_now + 1.second, learner_id: learner.id).access_token
  end

  def active_for_authentication?
    super && user_active?
  end

  def finish_enews_subscription
    if self.email_subscribed
      EnewsSubscription::set_status(self.email, 'subscribed', self.first_name, self.last_name)
    end
  end

  def confirm
    super

    # send MailChimp subscription data
    finish_enews_subscription

    self.state = "active"
    save(:validate => true)
    self.make_user_a_member
  end

  def inactive_message
    user_active? ? super : "You cannot login since your account has been suspended."
  end

  #
  # Determine if this user is an oauth user
  #
  def is_oauth_user?
    self.authentications.length > 0
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
      roles << Role.where(title: role).first_or_create
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

  def role_names
    roles.pluck(:title)
  end

  def make_user_a_member
    self.add_role('member')
  end

  # is this user the anonymous user?
  def anonymous?
    self == User.anonymous
  end

  def is_project_admin?(project=nil)
    if project
      self.admin_for_projects.where(id: project.id).exists?
    else
      self.admin_for_projects.exists?
    end
  end

  def is_project_researcher?(project = nil, allow_expired: false, check_can_manage_permission_forms: false)
    target_association = allow_expired ? _project_user_researchers_inc_expired : _project_user_researchers

    if check_can_manage_permission_forms
      if project
        target_association.where(project_id: project.id, can_manage_permission_forms: true).exists?
      else
        target_association.where(can_manage_permission_forms: true).exists?
      end
    else
      if project
        target_association.where(project_id: project.id).exists?
      else
        target_association.exists?
      end
    end
  end

  def expiration_date_for_project(project)
    project_user = self.project_users.where(project_id: project.id, is_researcher: true).first
    project_user&.expiration_date
  end

  def can_manage_permission_forms?(project = nil)
    return true if has_role?('admin')
    return true if is_project_admin?(project)
    return true if is_project_researcher?(project, check_can_manage_permission_forms: true)
    return false
  end

  def is_project_cohort_member?(project=nil)
    if project
      cohort_projects.include? project
    else
      cohort_projects.length > 0
    end
  end

  def is_project_member?(project=nil)
    is_project_admin?(project) || is_project_researcher?(project) || is_project_cohort_member?(project)
  end

  def is_researcher_for_clazz?(clazz, check_can_manage_permission_forms: false)
    # check if class has teacher in a cohort of a project the user is a researcher of using a explicit join to avoid a
    # bunch of unneeded object instantiation
    projects_scope = check_can_manage_permission_forms ? researcher_for_projects.where("can_manage_permission_forms = ?", true) : researcher_for_projects

    projects_scope
      .joins("INNER JOIN admin_cohorts __ac ON __ac.project_id = admin_projects.id")
      .joins("INNER JOIN admin_cohort_items __aci ON __aci.admin_cohort_id = __ac.id AND __aci.item_type = 'Portal::Teacher'")
      .joins("INNER JOIN portal_teachers __pt ON __pt.id = __aci.item_id")
      .joins("INNER JOIN portal_teacher_clazzes __ptc ON __ptc.teacher_id = __pt.id")
      .where("__ptc.clazz_id = ?", clazz.id)
      .count > 0
  end

  def is_project_admin_for_clazz?(clazz)
    # check if class has teacher in a cohort of a project the user is a admin of using a explicit join to avoid a
    # bunch of unneeded object instantiation
    admin_for_projects
      .joins("INNER JOIN admin_cohorts __ac ON __ac.project_id = admin_projects.id")
      .joins("INNER JOIN admin_cohort_items __aci ON __aci.admin_cohort_id = __ac.id AND __aci.item_type = 'Portal::Teacher'")
      .joins("INNER JOIN portal_teachers __pt ON __pt.id = __aci.item_id")
      .joins("INNER JOIN portal_teacher_clazzes __ptc ON __ptc.teacher_id = __pt.id")
      .where("__ptc.clazz_id = ?", clazz.id)
      .count > 0
  end

  def has_full_access_to_student_data?(clazz)
    # Only admins, class students, teachers and project admins have full access to student data. Start checks from
    # the "cheapest" queries so we don't need to execute complex queries if not necessary (e.g. is_project_admin_for_clazz).
    return true if has_role?('admin')
    return true if portal_student&.has_clazz?(clazz)
    return true if portal_teacher&.has_clazz?(clazz)
    return true if is_project_admin_for_clazz?(clazz)
    false
  end

  def add_role_for_project(role, project, expiration_date: nil, can_manage_permission_forms: false)
    role_attribute = "is_#{role}"
    project_user = project_users.find_by_project_id project.id
    project_user ||= Admin::ProjectUser.create!(project_id: project.id, user_id: self.id)
    project_user[role_attribute] = true
    project_user.expiration_date = expiration_date
    project_user.can_manage_permission_forms = can_manage_permission_forms
    project_user.save
  end

  def remove_role_for_project(role, project)
    if project_user = project_users.find_by_project_id(project.id)
      role_attribute = "is_#{role}"
      project_user[role_attribute] = false
      project_user.expiration_date = nil
      project_user.can_manage_permission_forms = false
      project_user.save
    end
  end

  def set_role_for_projects(role, possible_projects, selected_project_ids, expiration_dates={}, can_manage_permission_forms={})
  possible_projects.each do |project|
    if selected_project_ids.find { |id| id.to_i == project.id }
      add_role_for_project(
        role,
        project,
        expiration_date: expiration_dates[project.id.to_s],
        can_manage_permission_forms: can_manage_permission_forms[project.id.to_s] == 'true'
      )
    else
      remove_role_for_project(role, project)
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
      anonymous_user = User.where(login: "anonymous").first_or_create(
        :first_name            => "Anonymous",
        :last_name             => "User",
        :email                 => "anonymous@concord.org",
        :email_subscribed      => false,
        :password              => "password",
        :password_confirmation => "password"){|u| u.skip_notifications = true}
      anonymous_user.add_role('guest')
      @@anonymous_user = anonymous_user
    end
  end

  def school
    school_person = self.portal_teacher || self.portal_student
    if school_person
      school_person.school
    end
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

  def set_passive_users_as_pending
    if (self.state == 'passive' && (!self.confirmation_token.nil? && self.confirmed_at.nil?))
      self.update_attribute(:state, "pending")
    end
    self.reload
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

  def self.verified_imported_user?(login)
    user = User.find_by_login(login)
    imported_user = user.imported_user if user
    return imported_user.is_verified if imported_user
    return true
  end

  def has_active_classes?
    portal_teacher && (portal_teacher.clazzes.select{|c| c.is_archived == false }).count > 0
  end

  def has_portal_user_type?
    portal_teacher || portal_student
  end

  def admin_for_project_cohorts
    admin_for_projects.map {|p| p.cohorts}.flatten.uniq
  end

  def admin_for_project_admins
    admin_for_projects.map {|p| p.project_admins}.flatten.uniq
  end

  def admin_for_project_researchers
    admin_for_projects.map {|p| p.project_researchers}.flatten.uniq
  end

  def admin_for_project_teachers
    admin_for_project_cohorts.map {|c| c.teachers}.flatten.uniq
  end

  def admin_for_project_students
    admin_for_project_cohorts.map {|c| c.students}.flatten.uniq
  end

  def researcher_for_project_cohorts
    researcher_for_projects.map {|p| p.cohorts}.flatten.uniq
  end

  def researcher_for_project_teachers
    researcher_for_project_cohorts.map {|c| c.teachers}.flatten.uniq
  end

  def researcher_for_project_students
    researcher_for_project_cohorts.map {|c| c.students}.flatten.uniq
  end

  def cohorts
    teacher_cohorts | student_cohorts
  end

  def cohort_projects
    teacher_cohort_projects | student_cohort_projects
  end

  def projects
    cohort_projects | admin_for_projects | researcher_for_projects
  end

  protected

  def send_on_create_confirmation_instructions
    return if skip_notifications
    super
  end

  def make_activation_code
    self.deleted_at = nil
    self.activation_code = self.class.make_token
  end

end
