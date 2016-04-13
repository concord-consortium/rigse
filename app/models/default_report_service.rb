# This class mimics external_report.rb
class DefaultReportService
  DefaultReportServiceAppID   = 'DEFAULT_REPORT_SERVICE_CLIENT'
  ReportTokenValidFor = 2.hours

  def self.instance
    @instance || self.new()
  end

  def load_env(varname)
    result =  ENV[varname]
    unless result
      throw(Exception("Please add #{varname} to app_environment_variables.rb"))
    end
    result
  end

  def reportViewUrl
    load_env('REPORT_VIEW_URL')
  end

  def report_domain_matchers
    load_env('REPORT_DOMAINS')
  end

  def initialize
    found = Client.find_by_app_id(DefaultReportServiceAppID)
    @client = found || Client.new({
      app_id: DefaultReportServiceAppID,
      name: DefaultReportServiceAppID,
      app_secret: SecureRandom.uuid()
    })
    if @client.domain_matchers != report_domain_matchers
      @client.update_attribute(:domain_matchers, report_domain_matchers)
    end
  end

  # Return a the external_report url with parameters for the offering_api_url
  # and the short-lived bearer token for the user.
  def url_for(api_offering_url, user)
    grant = @client.updated_grant_for(user, ReportTokenValidFor)
    token = grant.access_token
    url = ERB::Util.url_encode(api_offering_url)
    "#{reportViewUrl}?reportUrl=#{url}&token=#{token}"
  end

end
