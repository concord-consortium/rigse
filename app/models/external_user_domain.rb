class ExternalUserDomain < ActiveRecord::Base
  
  has_many :external_users
  
  acts_as_replicatable
  
  validates_format_of :server_url, :with => URI::regexp(%w(http https))
  validates_length_of :name, :minimum => 1

  RINET_SAKAI          = 'rinet_sakai'
  RINET_SAKAI_TEST     = 'rinet_sakai_test'
  CC_SAKAI_TEST        = 'cc_sakai'

  @@external_domain_selection = CC_SAKAI_TEST

  URL_MAP = {
    'http://sakai.rinet.org'       => RINET_SAKAI,
    'http://test.sakai.rinet.org'  => RINET_SAKAI_TEST,
    'http://mooseman.concord.org'  => CC_SAKAI_TEST
  }
  
  class ExternalUserDomainError < StandardError
  end
  
  class <<self

    def login_exists?(external_login)
      User.login_exists?("#{external_login}_#{@@external_domain_selection}")
    end

    def login_does_not_exist?(external_login)
      User.login_does_not_exist?("#{external_login}_#{@@external_domain_selection}")
    end

    def find_user_by_external_login(external_login)
      raise ExternalUserDomain::ExternalUserDomainError, "no external domain selected" unless @@external_domain_selection
      User.find_by_login(external_login + '_' + @@external_domain_selection)
    end
    
    def create_user_with_external_login(params)
      raise ExternalUserDomain::ExternalUserDomainError, "no external domain selected" unless @@external_domain_selection
      params[:login] = "#{params[:login]}_#{@@external_domain_selection}"
      user = User.create!(params)
      user.register!
      user.activate!
      user
    end
    
    def external_domain_suffix
      raise ExternalUserDomain::ExternalUserDomainError, "no external domain selected" unless @@external_domain_selection
      @@external_domain_selection
    end
    
    def select_external_domain_by_server_url(server_url)
      @@external_domain_selection = ExternalUserDomain::URL_MAP[server_url]
    end
    
  end
end
