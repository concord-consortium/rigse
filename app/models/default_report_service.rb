class DefaultReportService
  def self.default_report_for_offering(offering)
    return nil unless offering.runnable
    return nil unless offering.runnable.respond_to?(:tool)
    return nil unless offering.runnable.tool
    source_type = offering.runnable.tool.source_type
    # Activities with nil source_type could accidentally match with External Reports
    # that have default_report_for_source_type = nil.
    return nil unless source_type
    ExternalReport
      .where(
        "default_report_for_source_type = ? AND (report_type = ? OR report_type = ?) AND allowed_for_students = true",
        source_type, ExternalReport::OfferingReport, ExternalReport::DeprecatedReport
      )
      .first
  end
end
