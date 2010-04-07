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
    'http://portfolio.ri.net/'       => RINET_SAKAI,
    'https://portfolio.ri.net/'      => RINET_SAKAI,
    'http://test.portfolio.ri.net/'  => RINET_SAKAI_TEST,
    'https://test.portfolio.ri.net/' => RINET_SAKAI_TEST,
    'http://moleman.concord.org/'    => CC_SAKAI_TEST,
    'https://moleman.concord.org/'   => CC_SAKAI_TEST
  }
  
  class ExternalUserDomainError < StandardError
  end
  
  class <<self

    # def login_exists?(external_login)
    #   User.login_exists?("#{external_login}_#{@@external_domain_selection}")
    # end
    # 
    # def login_does_not_exist?(external_login)
    #   User.login_does_not_exist?("#{external_login}_#{@@external_domain_selection}")
    # end

    def external_login_exists?(external_login)
      User.login_exists?(ExternalUserDomain.external_login_to_login(external_login))
    end

    def external_login_does_not_exist?(external_login)
      User.login_exists?(ExternalUserDomain.external_login_to_login(external_login))
    end

    def find_user_by_external_login(external_login)
      raise ExternalUserDomain::ExternalUserDomainError, "no external domain selected" unless @@external_domain_selection
      User.find_by_login(ExternalUserDomain.external_login_to_login(external_login))
    end
    
    def create_user_with_external_login(params)
      raise ExternalUserDomain::ExternalUserDomainError, "no external domain selected" unless @@external_domain_selection
      params[:login] = ExternalUserDomain.external_login_to_login(params[:login])
      user = User.create!(params)
      user.register!
      user.activate!
      user
    end

    def external_login_to_login(external_login)
      raise ExternalUserDomainError unless (external_login && external_login.length > 0)
      new_login = external_login.gsub(/'|`|\(|\)/, ' ').strip.gsub(/\s+/, '_')
      "#{new_login}_#{@@external_domain_selection}"
    end

    def login_to_external_login(login)
      raise ExternalUserDomainError unless (login && login.length > 0)
      login.gsub(/_#{external_domain_suffix}/,"")
    end
    
    def external_domain_suffix
      raise ExternalUserDomain::ExternalUserDomainError, "no external domain selected" unless @@external_domain_selection
      @@external_domain_selection
    end
    
    ## Look in config/rinet_data.yml for external_domain_url
    def select_external_domain_by_server_url(server_url)
      @@external_domain_selection = ExternalUserDomain::URL_MAP[server_url.last == '/' ? server_url : "#{server_url}/"]
    end
    
    def display_name
      "External User Domain"
    end
    
  end
end
