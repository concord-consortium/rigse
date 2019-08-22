require File.expand_path('../../spec_helper', __FILE__)

describe ExternalReport do
  let(:offering)        { FactoryBot.create(:portal_offering, {runnable: FactoryBot.create(:external_activity)}) }
  let(:external_report) { FactoryBot.create(:external_report, url: 'https://example.com?cool=true') }
  let(:portal_teacher)  { FactoryBot.create(:portal_teacher)}
  let(:extra_params)    { {} }

  describe "#url_for_offering" do
    subject { external_report.url_for_offering(offering, portal_teacher.user, 'https', 'perfect.host.com', extra_params) }

    it "should handle report urls with parameters" do
      expect(subject.scan('?').size).to eq(1)
      expect(subject).to include('cool=true')
    end

    describe "when report type is `offering`" do
      it "should include the correct parameters" do
        expect(subject).to include('reportType=offering', 'offering=', 'classOfferings=', 'class=', 'token=', 'username=')
      end

      it "should have correctly escaped url params" do
        uri = URI.parse(subject)
        query_hash = Rack::Utils.parse_query(uri.query)
        expect(query_hash['offering']).to start_with('https://')
        expect(query_hash['classOfferings']).to start_with('https://')
        expect(query_hash['class']).to start_with('https://')
      end

      describe "when extra params are provided" do
        let(:external_activity) { FactoryBot.create(:external_activity) }
        let(:investigation) { FactoryBot.create(:investigation) }
        let(:activity) { FactoryBot.create(:activity) }
        let(:offering) { FactoryBot.create(:portal_offering, {runnable: external_activity}) }
        let(:learner) { FactoryBot.create(:full_portal_learner, {offering: offering }) }
        let(:extra_params) { {activity_id: activity.id, student_id: learner.student.id} }

        before(:each) do
          investigation.activities << activity
          external_activity.template = investigation
          external_activity.save!
        end

        it "should include the correct parameters" do
          expect(subject).to include('activityIndex=0', "studentId=#{learner.user.id}")
        end
      end
    end

    describe "when report type is `deprecated-report`" do
      let(:external_report) { FactoryBot.create(:external_report, url: 'https://example.com?cool=true', report_type: 'deprecated-report') }

      it "should include the correct parameters" do
        expect(subject).to include('reportUrl=', 'token=')
      end

      it "should have correctly escaped url params" do
        uri = URI.parse(subject)
        query_hash = Rack::Utils.parse_query(uri.query)
        expect(query_hash['reportUrl']).to start_with('https://')
      end

      describe "when extra params are provided" do
        let(:external_activity) { FactoryBot.create(:external_activity) }
        let(:investigation) { FactoryBot.create(:investigation) }
        let(:activity) { FactoryBot.create(:activity) }
        let(:offering) { FactoryBot.create(:portal_offering, {runnable: external_activity}) }
        let(:learner) { FactoryBot.create(:full_portal_learner, {offering: offering }) }
        let(:extra_params) { {activity_id: activity.id, student_id: learner.student.id} }

        before(:each) do
          investigation.activities << activity
          external_activity.template = investigation
          external_activity.save!
        end

        it "reportUrl should include the correct parameters" do
          uri = URI.parse(subject)
          query_hash = Rack::Utils.parse_query(uri.query)
          expect(query_hash['reportUrl']).to include("activity_id=#{activity.id}", "student_ids%5B%5D=#{learner.student.id}")
        end
      end
    end
  end

  describe "#url_for_class" do
    subject { external_report.url_for_class(offering.clazz_id, portal_teacher.user, 'https', 'perfect.host.com') }

    it "should handle report urls with parameters" do
      expect(subject.scan('?').size).to eq(1)
      expect(subject).to include('cool=true')
    end
    it "should include the correct parameters" do
      expect(subject).to include('reportType=class', 'classOfferings=',
        'class=', 'token=', 'username=')
    end
    it "should have correctly escaped url params" do
      uri = URI.parse(subject)
      query_hash = Rack::Utils.parse_query(uri.query)
      expect(query_hash['class']).to start_with('https://')
      expect(query_hash['classOfferings']).to start_with('https://')
    end
  end


  # TODO: auto-generated
  describe '#options_for_client' do
    it 'options_for_client' do
      external_report = described_class.new
      result = external_report.options_for_client

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#options_for_report_type' do
    it 'options_for_report_type' do
      external_report = described_class.new
      result = external_report.options_for_report_type

      expect(result).not_to be_nil
    end
  end
end
