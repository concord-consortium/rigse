# This class mimics external_report.rb
class DefaultReportService
  DefaultReportServiceClientName = 'DEFAULT_REPORT_SERVICE_CLIENT'
  DefaultReportDeprecatedApiKey = "default-deprecated-api"
  DefaultReportDeprecatedApiName = "Default report (old API)"
  DefaultReportKey = "default"
  DefaultReportName = "Default report (Firestore)"
  ExternalReportKeyPrefix = "external-report-"

  attr_reader :external_report

  def self.current_report_key
    Admin::Settings.default_settings.default_report_service
  end

  def self.external_report_key(external_report)
    ExternalReportKeyPrefix + external_report.id.to_s
  end

  def self.select_options
    [
      [DefaultReportDeprecatedApiName, DefaultReportDeprecatedApiKey],
      [DefaultReportName, DefaultReportKey]
    ] + ExternalReport
      .where("(report_type = 'offering' OR report_type = 'deprecated-report') AND allowed_for_students = true")
      .map { |er| [er.name, external_report_key(er)] }
  end

  def self.load_env(varname)
    result =  ENV[varname]
    unless result
      throw(Exception("Please add #{varname} to app_environment_variables.rb"))
    end
    result
  end

  def self.report_view_url
    load_env('REPORT_VIEW_URL')
  end

  def self.report_domain_matchers
    load_env('REPORT_DOMAINS')
  end

  def initialize
    # If the client is not available, it's created and saved in the database.
    @client = Client.find_by_app_id(DefaultReportServiceClientName) || Client.create({
      app_id: DefaultReportServiceClientName,
      name: DefaultReportServiceClientName,
      app_secret: SecureRandom.uuid()
    })
    if @client.domain_matchers != DefaultReportService::report_domain_matchers
      @client.update_attribute(:domain_matchers, DefaultReportService::report_domain_matchers)
    end

    # Note that external_report may or may not be saved in the database. When it's a default report based on
    # ENV variables, it won't be saved (there's no need for that).
    @external_report = external_report_from_key(DefaultReportService::current_report_key)
  end

  def external_report_from_key(key)
    if key == DefaultReportDeprecatedApiKey || key == DefaultReportKey
      deprecatd = key == DefaultReportDeprecatedApiKey
      # Note that the default report is using `.new` to it's never saved in the database. That seems fine,
      # as there's no need to save it or edit its options later.
      return ExternalReport.new({
        report_type: deprecatd ? ExternalReport::DeprecatedReport : ExternalReport::OfferingReport,
        name: deprecatd ? DefaultReportDeprecatedApiName : DefaultReportName,
        url: DefaultReportService::report_view_url,
        launch_text: "Report",
        client: @client,
        allowed_for_students: true
      })
    end
    id = key.split(ExternalReportKeyPrefix)[1]
    return nil unless id
    ExternalReport.find(id)
  end

  def name
    @external_report && @external_report.name
  end
end
