# frozen_string_literal: false

require "spec_helper"

describe DefaultReportService do
  let(:external_activity) { FactoryBot.create(:external_activity) }
  let(:offering) do
    FactoryBot.create(
      :portal_offering,
      runnable_id: external_activity.id,
      runnable_type: "ExternalActivity"
    )
  end

  before(:each) do
    # Ensure default report is created
    @default_report = FactoryBot.create(:default_lara_report)
  end

  describe "#default_report_for_offering" do
    describe "when default report is configured correctly and offering source type matches report type" do
      it "returns default report service" do
        expect(DefaultReportService.default_report_for_offering(offering)).to eql(@default_report)
      end
    end

    describe "when default report attributes are incorrect" do
      it "returns nil when external activity source type is nil" do
        external_activity.tool.update_attributes(source_type: nil)
        @default_report.update_attributes(default_report_for_source_type: nil)
        expect(DefaultReportService.default_report_for_offering(offering)).to eql(nil)
      end
      it "returns nil when report is not allowed for students" do
        @default_report.update_attributes(allowed_for_students: false)
        expect(DefaultReportService.default_report_for_offering(offering)).to eql(nil)
      end
      it "returns nil when report has wrong type" do
        @default_report.update_attributes(report_type: "class")
        expect(DefaultReportService.default_report_for_offering(offering)).to eql(nil)
      end
      it "returns nil when report source type doesn't match runnable source type" do
        external_activity.tool.update_attributes(source_type: "NOT-LARA")
        expect(DefaultReportService.default_report_for_offering(offering)).to eql(nil)
      end
      it "returns nil when external activity tool is nil" do
        external_activity.update_attributes(tool_id: nil)
        @default_report.update_attributes(default_report_for_source_type: nil)
        expect(DefaultReportService.default_report_for_offering(offering)).to eql(nil)
      end
    end
  end
end
