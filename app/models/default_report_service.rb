# This class mimics external_report.rb
class DefaultReportService
  DefaultReportServiceAppID   = 'DEFAULT_REPORT_SERVICE_CLIENT'
  DefaultReportDomainMatchers = '*.concord.org concord-consortium.github.io localhost'
  ReportViewUrl = 'https://concord-consortium.github.io/portal-report/'


  ReportTokenValidFor = 2.hours

  def self.instance
    @instance || self.new()
  end

  def reportViewUrl
    ENV['REPORT_VIEW_URL'] || ReportViewUrl
  end

  def initialize
    found = Client.find_by_app_id(DefaultReportServiceAppID)
    @client = found || Client.new({
      app_id: DefaultReportServiceAppID,
      name: DefaultReportServiceAppID,
      app_secret: SecureRandom.uuid()
    })
    if @client.domain_matchers != DefaultReportDomainMatchers
      @client.update_attribute(:domain_matchers, DefaultReportDomainMatchers)
    end
  end

  # Return a the external_report url with parameters for the offering_api_url
  # and the short-lived bearer token for the user.
  def url_for(api_offering_url, user)
    grant = @client.updated_grant_for(user, ReportTokenValidFor)
    token = grant.access_token
    "#{reportViewUrl}?reportUrl=#{api_offering_url}&token=#{token}"
  end

end
